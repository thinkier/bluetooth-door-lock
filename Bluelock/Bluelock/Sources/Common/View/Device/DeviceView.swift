//
//  DeviceView.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import Combine
import CoreBluetooth
import SwiftUI

struct DeviceView: View {
    @ObservedObject var blueCentral: BluelockCentralDelegate

    var peripheral: CBPeripheral
    var currentLock: BluelockPeripheralDelegate

    @State var update: Cancellable?
    @State var scanned: ScannedPeripheral?
    @State var wantsConnection: Bool = false

    @State var config = DeviceConfiguration()

    var body: some View {
        VStack {
            List {
                DeviceDiagnosticView(peripheral: peripheral, config: $config, currentLock: currentLock, scanned: $scanned, wantsConnection: $wantsConnection)
                DeviceAutomationView(peripheral: peripheral, config: $config)
                DeviceStatusView(peripheral: peripheral, config: $config, currentLock: currentLock, wantsConnection: $wantsConnection)
            }
        }
        .onAppear {
            if let config = BluelockDb.main.retrieve(peripheral: peripheral) {
                self.config = config
            }

            self.update?.cancel()
            self.update = DispatchQueue.main.schedule(after: .init(.now()), interval: .init(.milliseconds(100))) {
                scanned = blueCentral.getScannedPeripheral(peripheral.identifier)

                if wantsConnection {
                    if peripheral.state == .disconnected && !config.autoconnect {
                        wantsConnection = false
                    }
                } else {
                    if peripheral.state == .connected {
                        wantsConnection = true
                    }
                }
            }
        }
        .onDisappear {
            self.update?.cancel()
        }
        .onChange(of: wantsConnection) { _, connect in
            if connect {
                if peripheral.state == .disconnected {
                    blueCentral.connect(peripheral)
                }
            } else {
                if peripheral.state == .connected {
                    self.scanned = ScannedPeripheral(name: nil, rssi: currentLock.rssi, txPowerLevel: currentLock.txPower, distance: currentLock.distance(), date: Date(), peripheral: peripheral)
                    blueCentral.disconnect(peripheral)
                }
            }
        }
        .navigationTitle(peripheral.name ?? "Unknown Device")
    }
}
