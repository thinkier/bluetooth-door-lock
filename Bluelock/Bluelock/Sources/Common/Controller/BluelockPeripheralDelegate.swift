//
//  BluelockDelegate.swift
//  Bluelock
//
//  Created by Matthew on 9/4/2024.
//

import Foundation
import CoreBluetooth
//import CoreHaptics
import UserNotifications

public class BluelockPeripheralDelegate: NSObject, CBPeripheralDelegate, ObservableObject {
    //    let engine: CHHapticEngine
    
    @Published var rssi: Float
    @Published var txPower: Float
    @Published var lastUpdated: ContinuousClock.Instant?
    @Published var lockState: DeviceReportedState?
    
    var peripheral: CBPeripheral
    var config: DeviceConfiguration?
    
    init(peripheral: CBPeripheral, rssi: Float, txPower: Float) {
        self.peripheral = peripheral
        self.txPower = txPower
        self.rssi = rssi
        
        //        engine = try! CHHapticEngine()
        //        try! engine.start()
    }
    
    public func setState(_ peripheral: CBPeripheral, locked: Bool) {
        guard let tx = getWriteCharacteristic(peripheral) else {
            return
        }
        
        peripheral.writeValue(((locked ? "l" : "u") + "wd").data(using: .utf8)!, for: tx, type: .withResponse)
        dispatchNotification(locked: locked)
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
    
    func dispatchNotification(locked: Bool) {
        let name = peripheral.name ?? "Unknown Device"
        let lockedString = (locked ? "Locked" : "Unlocked")
        let uuidString = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = lockedString + ": " + name
        content.body = name + " was " + lockedString.lowercased()
        content.sound =  .defaultCritical
        content.interruptionLevel = .critical
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
            .filter { $0.uuid == .NordicUartCharaTxID }
            .first
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI rssi: NSNumber, error: (any Error)?) {
        self.rssi = Float(truncating: rssi)
        self.lastUpdated = ContinuousClock.now
        
        if let newConfig = BluelockDb.main.retrieve(peripheral: peripheral) {
            config = newConfig
        }
        
        if let config = config {
            guard let lockState = self.lockState else {
                return
            }
            
            let distance = estimateDistance()
            let qual = LinkQuality(distance: distance)
            
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
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        for characteristic in service.characteristics ?? [] {
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        for service in peripheral.services ?? [] {
            if service.uuid == .NordicUartServiceID {
                peripheral.discoverCharacteristics([.NordicUartCharaTxID, .NordicUartCharaRxID], for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: (any Error)?) {
        switch characteristic.uuid {
        case .NordicUartCharaTxID:
            peripheral.writeValue("s".data(using: .utf8)!, for: characteristic, type: .withResponse)
            break;
        case .NordicUartCharaRxID:
            peripheral.setNotifyValue(true, for: characteristic)
            break;
        default:
            return;
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if characteristic.uuid == .NordicUartCharaRxID && characteristic.value != nil {
            peripheral.readRSSI()
            
            guard let repState = try? JSONDecoder().decode(DeviceReportedState.self, from: characteristic.value!) else {
                return
            }
            
            lockState = repState
            lastUpdated = ContinuousClock.now
        }
    }
    
    public func estimateDistance() -> Float {
        return Bluelock.estimateDistance(rssi: rssi, txPower: txPower)
    }
}
