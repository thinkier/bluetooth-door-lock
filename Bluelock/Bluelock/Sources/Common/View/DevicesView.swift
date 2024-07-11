//
//  DevicesView.swift
//  Bluelock
//
//  Created by Matthew on 8/4/2024.
//

import Combine
import CoreBluetooth
import SwiftUI

struct DevicesView: View {
    @ObservedObject var blueCentral: BluelockCentralDelegate
    @State var update: Cancellable?
    @State var knownPeriphs: [BluelockPeripheralDelegate] = []
    @State var bestPeriphs: [ScannedPeripheral] = []

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if !knownPeriphs.isEmpty {
                        Section("Known Devices") {
                            ForEach(knownPeriphs, id: \.peripheral.identifier) { periph in
                                NavigationLink(value: periph.peripheral) {
                                    HStack {
                                        Text(periph.peripheral.name ?? "Unknown Device")
                                        Spacer()
                                        ConnectionIcon(
                                            isAutoConnect: BluelockDb.main.retrieve(peripheral: periph.peripheral)?.autoconnect,
                                            isConnected: periph.peripheral.state == .connected
                                        )
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
                    knownPeriphs = blueCentral.peripherals
                        .filter { BluelockDb.main.retrieve(id: $0.key) != nil }
                        .map { $0.value }
                    let bestPeriphs = blueCentral.getBestPeripherals()
                        .filter { scanned in
                            !knownPeriphs.contains(where: { known in
                                scanned.peripheral.identifier == known.peripheral.identifier
                            })
                        }
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
