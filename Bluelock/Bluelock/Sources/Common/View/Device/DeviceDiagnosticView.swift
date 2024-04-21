//
//  DeviceDiagnosticView.swift
//  Bluelock
//
//  Created by Matthew on 13/4/2024.
//

import SwiftUI
import CoreBluetooth
import Combine

struct DeviceDiagnosticView: View {
    var peripheral: CBPeripheral
    
    @Binding var config: DeviceConfiguration
    @ObservedObject var currentLock: BluelockPeripheralDelegate
    @Binding var scanned: ScannedPeripheral?
    @Binding var wantsConnection: Bool
    
    @State var isInRange: Bool = false
    @State var update: Cancellable?
    
    var body: some View {
        Section("Diagnostic") {
            HStack {
                Label("Status", systemImage: "info.square")
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                ConnectionIcon(isAutoConnect: config.autoconnect, isConnected: peripheral.state == .connected)
                if isInRange {
                    LinkQualityIcon(rssi: currentLock.rssi, txPower: currentLock.txPower)
                } else {
                    LinkQualityIcon(scanned?.linkQuality() ?? .none)
                }
            }
            if isInRange {
                HStack {
                    Label("Signal Strength", systemImage: "cellularbars")
                        .symbolRenderingMode(.hierarchical)
                    Spacer()
                    Text(Int(scanned?.rssi ?? currentLock.rssi).description + "dBm")
                        .foregroundStyle(Color.secondary)
                }
                HStack {
                    Label("Distance Estimate", systemImage: "ruler")
                        .symbolRenderingMode(.hierarchical)
                    Spacer()
                    Text((scanned?.distance ?? currentLock.estimateDistance()).description + "m")
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .onAppear {
            self.update?.cancel()
            self.update = DispatchQueue.main.schedule(after: .init(.now()), interval: .milliseconds(250)) {
                isInRange = peripheral.state == .connected || scanned != nil
            }
        }
        .onDisappear {
            self.update?.cancel()
        }
    }
}
