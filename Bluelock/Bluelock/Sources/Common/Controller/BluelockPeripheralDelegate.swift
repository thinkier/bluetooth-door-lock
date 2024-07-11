//
//  BluelockPeripheralDelegate.swift
//  Bluelock
//
//  Created by Matthew on 9/4/2024.
//

import CoreBluetooth
import Foundation

// import CoreHaptics
import UserNotifications
#if canImport(ActivityKit)
    import ActivityKit
#endif

public class BluelockPeripheralDelegate: NSObject, CBPeripheralDelegate, ObservableObject {
    //    let engine: CHHapticEngine

    @Published var rssi: Float
    @Published var txPower: Float = 0
    @Published var lastUpdated: ContinuousClock.Instant?
    @Published var lastActuated: ContinuousClock.Instant?
    @Published var lockState: DeviceReportedState?
    @Published var lockIntentLocked: Bool? = nil
    #if canImport(ActivityKit)
        @Published var activity: Activity<LockAttributes>?
    #endif

    var peripheral: CBPeripheral
    var config: DeviceConfiguration?

    init(peripheral: CBPeripheral, rssi: Float?, txPower: Float?) {
        self.peripheral = peripheral

        if let txPower = txPower {
            self.txPower = txPower
        } else {
            peripheral.discoverServices([.BLETxPowerServiceID])
        }

        self.rssi = rssi ?? -128
        if rssi == nil {
            peripheral.readRSSI()
        }

        #if canImport(ActivityKit)
            activity = Activity<LockAttributes>.activities.filter { $0.attributes.peer == peripheral.identifier }.first
        #endif

        //        engine = try! CHHapticEngine()
        //        try! engine.start()
    }

    convenience init(peripheral: CBPeripheral) {
        self.init(peripheral: peripheral, rssi: nil, txPower: nil)
    }

    public func setState(_ peripheral: CBPeripheral, locked: Bool) {
        guard let tx = getWriteCharacteristic(peripheral) else {
            return
        }

        lockIntentLocked = locked

        peripheral.writeValue(((locked ? "l" : "u") + "wd").data(using: .utf8)!, for: tx, type: .withResponse)
        //        showNotification(locked: locked)
        //        playHaptics(locked: locked)
    }

    //    /// Does not work while backgrounded
    //    func playHaptics(locked: Bool) {
    //        do {
    //            let sharp = CHHapticEvent(
    //                eventType: .hapticContinuous,
    //                parameters: [
    //                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
    //                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
    //                ],
    //                relativeTime: locked ? 0.2 : 0,
    //                duration: 0.2
    //            );
    //            let dull = CHHapticEvent(
    //                eventType: .hapticContinuous,
    //                parameters: [
    //                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
    //                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
    //                ],
    //                relativeTime: locked ? 0 : 0.2,
    //                duration: 0.2
    //            );
    //            let pattern = try CHHapticPattern(events: [dull, sharp], parameters: [])
    //
    //            try engine.makePlayer(with: pattern).start(atTime: 0)
    //        } catch let error {
    //            print("Haptic Playback Error: \(error)")
    //        }
    //    }

    func showNotification(locked: Bool) {
        let name = peripheral.name ?? "Unknown Device"
        let lockedString = (locked ? "Locked" : "Unlocked")
        let uuidString = UUID().uuidString
        let critical = !locked && lockIntentLocked != locked

        let content = UNMutableNotificationContent()
        content.title = lockedString + ": " + name
        content.body = name + " was " + lockedString.lowercased()
        content.sound = critical ? .defaultCriticalSound(withAudioVolume: 0.5) : .default
        content.interruptionLevel = critical ? .critical : .timeSensitive
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)

        // Schedule the request with the system.
        let notif = UNUserNotificationCenter.current()
        notif.removeAllDeliveredNotifications()
        Task {
            do {
                try await notif.add(request)
                DispatchQueue.main.schedule(after: .init(.now().advanced(by: .seconds(2)))) {
                    notif.removeDeliveredNotifications(withIdentifiers: [uuidString])
                }
            } catch {
                print("Notification Error: \(error)")
            }
        }
    }

    func getWriteCharacteristic(_ peripheral: CBPeripheral) -> CBCharacteristic? {
        peripheral.services?
            .filter { $0.uuid == .NordicUartServiceID }
            .first?
            .characteristics?
            .filter { $0.uuid == .NordicUartTxCharaID }
            .first
    }

    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI rssi: NSNumber, error _: (any Error)?) {
        self.rssi = Float(truncating: rssi)
        lastUpdated = ContinuousClock.now

        if let newConfig = BluelockDb.main.retrieve(peripheral: peripheral) {
            config = newConfig
        }

        if (lastActuated?.duration(to: ContinuousClock.now)).map({ $0 < .seconds(2) }) ?? false {
            return
        }

        if let config = config {
            guard let lockState = lockState else {
                return
            }

            let distance = distance()
            let qual = LinkQuality(distance: distance)

            updateToUser(lockState: lockState, linkQuality: qual)

            if config.autounlock && lockState.closed == true && lockState.locked {
                if qual == .great {
                    setState(peripheral, locked: false)
                }
            }
            if config.autolock && lockState.closed == true && !lockState.locked {
                if qual != .great {
                    setState(peripheral, locked: true)
                }
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: (any Error)?) {
        for characteristic in service.characteristics ?? [] {
            peripheral.discoverDescriptors(for: characteristic)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: (any Error)?) {
        for service in peripheral.services ?? [] {
            switch service.uuid {
            case .NordicUartServiceID:
                peripheral.discoverCharacteristics([.NordicUartTxCharaID, .NordicUartRxCharaID], for: service)
                continue
            case .BLETxPowerServiceID:
                peripheral.discoverCharacteristics([.BLETxPowerLevelCharaID], for: service)
                continue
            default:
                continue
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error _: (any Error)?) {
        switch characteristic.uuid {
        case .NordicUartTxCharaID:
            peripheral.writeValue("s".data(using: .utf8)!, for: characteristic, type: .withResponse)
        case .NordicUartRxCharaID:
            peripheral.setNotifyValue(true, for: characteristic)
        case .BLETxPowerLevelCharaID:
            peripheral.readValue(for: characteristic)
        default:
            return
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: (any Error)?) {
        if characteristic.value == nil {
            return
        }

        switch characteristic.uuid {
        case .NordicUartRxCharaID:
            peripheral.readRSSI()

            guard let repState = try? JSONDecoder().decode(DeviceReportedState.self, from: characteristic.value!) else {
                return
            }

            if lockState != repState {
                updateToUser(lockState: repState, linkQuality: LinkQuality(distance: distance()))
                if lockState != nil {
                    lastActuated = ContinuousClock.now
                }
            }

            lockState = repState
            lastUpdated = ContinuousClock.now
        case .BLETxPowerLevelCharaID:
            var power: Int8 = 0
            NSData(data: characteristic.value!).getBytes(&power, length: 1)
            txPower = Float(power)
        default: return
        }
    }

    public func updateToUser(lockState: DeviceReportedState?, linkQuality: LinkQuality) {
        #if canImport(ActivityKit)
            Task {
                let content = ActivityContent(
                    state: LockAttributes.ContentState(
                        lockState: lockState,
                        linkQuality: linkQuality
                    ), staleDate: nil
                )
                var alertConfiguration: AlertConfiguration? = nil

                /// Until such time that Live Activities can dispatch Time Sensitive / Critical Alerts, this isn't very useful.
                // if let lockState = lockState {
                //     if lockState != self.lockState {
                //         alertConfiguration = AlertConfiguration(
                //             title: lockState.locked ? "Locked" : "Unlocked",
                //             body: LocalizedStringResource(stringLiteral: peripheral.name ?? "Unknown Device"),
                //             sound: .default)
                //     }
                // }

                await activity?.update(content,
                                       alertConfiguration: alertConfiguration)
            }

            // if activity?.activityState == .active {
            //     return
            // }
        #endif
        if self.lockState == nil {
            return
        }
        guard let lockState = lockState else {
            return
        }
        if !lockState.closed {
            return
        }
        if lockState.locked == self.lockState?.locked {
            return
        }
        showNotification(locked: lockState.locked)
    }

    public func distance() -> Float {
        return estimateDistance(rssi: rssi, txPower: txPower)
    }
}
