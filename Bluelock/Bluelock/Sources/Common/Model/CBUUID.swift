//
//  CBUUID.swift
//  Bluelock
//
//  Created by Matthew on 9/4/2024.
//

import CoreBluetooth
import Foundation

public extension CBUUID {
    /// Bluelock Advertised Service
    static let BluelockServiceID = CBUUID(string: "183B")
    /// Standards-conforming BLE Battery Service ID
    static let BLEBatteryServiceID = CBUUID(string: "180F")
    /// Standards-conforming BLE TX Power Service ID
    static let BLETxPowerServiceID = CBUUID(string: "1804")
    /// Standards-conforming BLE TX Power Level Characteristic ID
    static let BLETxPowerLevelCharaID = CBUUID(string: "2A07")
    /// Nordic UART Service
    static let NordicUartServiceID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    /// Nordic UART TX Characteristic
    static let NordicUartTxCharaID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    /// Nordic UART RX Characteristic
    static let NordicUartRxCharaID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
}
