//
//  ScannedPeripheral.swift
//  Bluelock
//
//  Created by Matthew on 9/4/2024.
//

import Foundation
import CoreBluetooth

public struct ScannedPeripheral: Hashable {
    /// Name supplied by the peripheral's broadcasts
    public var name: String?
    /// Absolute RSSI as reported by receivers
    public var rssi: Float
    /// TxPowerLevel as reported by the Peripheral's advertising data
    public var txPowerLevel: Float
    /// Estimated distance based on TxPowerLevel
    public var distance: Float
    /// When the peripheral was detected
    public var date: Date
    /// Handle to connect to
    public var peripheral: CBPeripheral
    
    public func linkQuality() -> LinkQuality {
        LinkQuality(distance: distance)
    }
}
