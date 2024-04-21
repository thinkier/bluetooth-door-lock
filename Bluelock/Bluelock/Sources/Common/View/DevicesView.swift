//
//  DevicesView.swift
//  Bluelock
//
//  Created by Matthew on 8/4/2024.
//

import SwiftUI
import Combine
import CoreBluetooth

struct DevicesView: View {
    @ObservedObject var blueCentral: BluelockCentralDelegate
    @State var update: Cancellable?
    @State var bestPeriphs: [ScannedPeripheral] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if !blueCentral.peripherals.isEmpty {
                        Section("Known Devices") {
                            ForEach(blueCentral.peripherals.values.shuffled(), id: \.peripheral.identifier) { periph in
                                NavigationLink(value: periph.peripheral) {
                                    HStack {
                                        Text(periph.peripheral.name ?? "Unknown Device")
                                        Spacer()
                                        ConnectionIcon(isConnected: periph.peripheral.state == .connected)
                                        if periph.peripheral.state == .connected {
                                            LinkQualityIcon(rssi: periph.rssi, txPower: periph.txPower)
                                        } else {
                                            LinkQualityIcon(.none)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if !bestPeriphs.isEmpty {
                        Section("Nearby Devices") {
                            ForEach(bestPeriphs, id: \.peripheral) { scanned in
                                DeviceEntryView(blueCentral: blueCentral, scanned: scanned)
                            }
                        }
                    }
                }
                
                if bestPeriphs.isEmpty {
                    VStack {
                        Text("No Nearby Devices Found")
                        Spacer()
                    }
                }
            }
            .navigationDestination(for: CBPeripheral.self) {
                DeviceView(blueCentral: blueCentral, peripheral: $0, currentLock: blueCentral.getPeripheralDelegate($0))
            }
            .onAppear {
                self.update?.cancel()
                self.update = DispatchQueue.main.schedule(after: .init(.now()), interval: .init(.milliseconds(100))) {
                    let bestPeriphs = blueCentral.getBestPeripherals()
                        .filter { blueCentral.peripherals[$0.peripheral.identifier] == nil }
                    self.bestPeriphs = bestPeriphs
                }
            }
            .onDisappear {
                self.update?.cancel()
            }
            .navigationTitle("Devices")
        }
    }
}
