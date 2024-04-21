//
//  DeviceEntryView.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

struct DeviceEntryView: View {
    @ObservedObject var blueCentral: BluelockCentralDelegate
    var scanned: ScannedPeripheral
    
    var body: some View {
        NavigationLink(value: scanned.peripheral) {
            HStack {
                Text(scanned.name ?? "Unknown Device")
                Spacer()
                ConnectionIcon(isAutoConnect: nil, isConnected: scanned.peripheral.state == .connected)
                LinkQualityIcon(scanned.linkQuality())
            }
        }
    }
}
