//
//  BluelockCentralDelegate.swift
//  Bluelock
//
//  Created by Matthew on 8/4/2024.
//

import Combine
import CoreBluetooth
import Foundation
#if canImport(ActivityKit)
    import ActivityKit
#endif

public class BluelockCentralDelegate: NSObject, CBCentralManagerDelegate, ObservableObject {
    @Published var scanned: [ScannedPeripheral] = []
    @Published var peripherals: [UUID: BluelockPeripheralDelegate] = [:]

    private var central: CBCentralManager?
    private var handles: [Cancellable] = []

    override public init() {
        super.init()
        handles.append(DispatchQueue.main.schedule(after: .init(.now()), interval: .seconds(1), scanReduce))
        central = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionShowPowerAlertKey: true,
            CBCentralManagerOptionRestoreIdentifierKey: "main",
        ])
    }

    deinit {
        central?.stopScan()
        handles.forEach { $0.cancel() }
    }

    func scanReduce() {
        scanned = scanned.filter { periph in
            NSDate().timeIntervalSince(periph.date as Date) <= 2
        }
    }

    public func getPeripheralDelegate(_ peripheral: CBPeripheral) -> BluelockPeripheralDelegate {
        if peripherals[peripheral.identifier] == nil {
            let lock = getScannedPeripheral(peripheral.identifier)
                .map {
                    BluelockPeripheralDelegate(peripheral: peripheral, rssi: $0.rssi, txPower: $0.txPowerLevel)
                }
                ?? BluelockPeripheralDelegate(peripheral: peripheral)
            peripherals.updateValue(lock, forKey: peripheral.identifier)
        }

        return peripherals[peripheral.identifier]!
    }

    public func connect(_ peripheral: CBPeripheral) {
        peripheral.delegate = getPeripheralDelegate(peripheral)

        central?.connect(peripheral)
    }

    public func disconnect(_ peripheral: CBPeripheral) {
        central?.cancelPeripheralConnection(peripheral)
    }

    public func getScannedPeripheral(_ identifier: UUID) -> ScannedPeripheral? {
        getBestPeripherals().filter { scanned in
            scanned.peripheral.identifier == identifier
        }.first
    }

    public func getBestPeripherals() -> [ScannedPeripheral] {
        var reduced_buf: [UUID: ScannedPeripheral] = [:]

        for scanned in scanned {
            let id = scanned.peripheral.identifier

            if reduced_buf.contains(where: { k, _ in id == k }) {
                let buffered = reduced_buf[id]!

                reduced_buf[id]!.name = buffered.name ?? scanned.name
                reduced_buf[id]!.rssi = buffered.rssi < scanned.rssi ? scanned.rssi : buffered.rssi
                reduced_buf[id]!.distance = buffered.distance < scanned.distance ? buffered.distance : scanned.distance
                reduced_buf[id]!.date = buffered.date < scanned.date ? scanned.date : buffered.date
            } else {
                reduced_buf.updateValue(scanned, forKey: id)
            }
        }

        var sort_buf = reduced_buf.map { _, v in v }
        sort_buf.sort(by: { a, b in a.distance < b.distance })
        return sort_buf
    }

    public func centralManager(_: CBCentralManager, willRestoreState _: [String: Any]) {
        // No additional handling required
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("CBCentralManager State: Powered On")
        case .resetting:
            print("CBCentralManager State: Resetting")
        case .unsupported:
            print("CBCentralManager State: Unsupported")
        case .unauthorized:
            print("CBCentralManager State: Unauthorized")
        case .poweredOff:
            print("CBCentralManager State: Powered Off")
        default:
            print("CBCentralManager State: Unknown")
        }

        if central.state == .poweredOn {
            BluelockDb.main.retrieveAllBonded()
                .map { id, conf in
                    (central.retrievePeripherals(withIdentifiers: [id]).first, conf)
                }
                .filter { $0.0 != nil }
                .map { ($0.0!, $0.1) }
                .forEach { periph, conf in
                    if conf.autoconnect || periph.state == .connected {
                        self.connect(periph)
                    } else {
                        let _ = self.getPeripheralDelegate(periph)
                    }
                }
            central.scanForPeripherals(withServices: [.BluelockServiceID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }

    @MainActor
    public func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        if rssi == 127 { return }

        let ts: CFNumber = advertisementData["kCBAdvDataTimestamp"] as! CFNumber
        let date = NSDate(timeIntervalSinceReferenceDate: Double(truncating: ts))
        let name: CFString? = advertisementData["kCBAdvDataLocalName"] as! CFString?
        let txPower = Float(truncating: advertisementData["kCBAdvDataTxPowerLevel"] as! CFNumber? ?? 8)
        let dist = estimateDistance(rssi: rssi.floatValue, txPower: txPower)

        if BluelockDb.main.retrieve(peripheral: peripheral) != nil {
            let delegate = getPeripheralDelegate(peripheral)
            delegate.txPower = txPower
        }

        if dist < 10000 {
            scanned.append(ScannedPeripheral(name: name as String?, rssi: Float(truncating: rssi), txPowerLevel: txPower, distance: dist, date: date as Date, peripheral: peripheral))

            if peripheral.state == .disconnected && BluelockDb.main.retrieve(peripheral: peripheral)?.autoconnect == true {
                connect(peripheral)
            }
        }

        #if canImport(ActivityKit)
            let del = getPeripheralDelegate(peripheral)
            del.updateToUser(lockState: del.lockState, linkQuality: LinkQuality(distance: dist))
        #endif
    }

    @MainActor
    public func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([.NordicUartServiceID, .BluelockServiceID, .BLETxPowerServiceID, .BLEBatteryServiceID])
    }

    @MainActor
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error _: (any Error)?) {
        handleDisconnect(central, peripheral: peripheral)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: (any Error)?) {
        handleDisconnect(central, peripheral: peripheral)
    }

    @MainActor
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, timestamp _: CFAbsoluteTime, isReconnecting _: Bool, error _: (any Error)?) {
        handleDisconnect(central, peripheral: peripheral)
    }

    public func handleDisconnect(_ central: CBCentralManager, peripheral: CBPeripheral) {
        if let conf = BluelockDb.main.retrieve(peripheral: peripheral) {
            if conf.autoconnect {
                central.connect(peripheral)
            } else {
                #if canImport(ActivityKit)
                    // getPeripheralDelegate(peripheral).activity?.end()
                #endif
            }
        }
    }
}

/// Returns the best-guess open-air distance in metres
///
/// https://stackoverflow.com/a/27550658
public func estimateDistance(rssi: Float, txPower: Float = 0) -> Float {
    return (pow(10, (txPower - rssi) / (10 * 2)) / 1e2).rounded() / 1e1
}
