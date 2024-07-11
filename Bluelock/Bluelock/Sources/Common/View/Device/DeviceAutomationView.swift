//
//  DeviceAutomationView.swift
//  Bluelock
//
//  Created by Matthew on 13/4/2024.
//

import CoreBluetooth
import SwiftUI

struct DeviceAutomationView: View {
    var peripheral: CBPeripheral

    @Binding var config: DeviceConfiguration

    var body: some View {
        Section("Automation") {
            Toggle("Auto Connect", systemImage: "wave.3.left", isOn: $config.autoconnect)
                .symbolRenderingMode(.hierarchical)
            Toggle("Auto Unlock", systemImage: "lock.open.trianglebadge.exclamationmark.fill", isOn: $config.autounlock)
                .symbolRenderingMode(.hierarchical)
            Toggle("Auto Lock", systemImage: "lock.trianglebadge.exclamationmark.fill", isOn: $config.autolock)
                .symbolRenderingMode(.hierarchical)
        }
        .onChange(of: config) {
            BluelockDb.main.update(config: config, peripheral: peripheral)
        }
    }
}
