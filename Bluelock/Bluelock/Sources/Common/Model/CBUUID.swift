//
//  CBUUID.swift
//  Bluelock
//
//  Created by Matthew on 9/4/2024.
//

import Foundation
import CoreBluetooth

extension CBUUID {
    /// Bluelock Custom Service
    public static let BluelockServiceID = CBUUID.init(string: "018EE101-012F-7597-982C-6D36E115DC1C");
    /// Standards-conforming BLE TX Power Service ID
    public static let BLETxPowerServiceID = CBUUID.init(string: "1804");
    /// Standards-conforming BLE TX Power Level Characteristic ID
    public static let BLETxPowerLevelCharaID = CBUUID.init(string: "2A07");
    /// Nordic UART Service
    public static let NordicUartServiceID = CBUUID.init(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
    /// Nordic UART TX Characteristic
    public static let NordicUartTxCharaID = CBUUID.init(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
    /// Nordic UART RX Characteristic
    public static let NordicUartRxCharaID = CBUUID.init(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
}
