//
//  DeviceStatusView.swift
//  Bluelock
//
//  Created by Matthew on 13/4/2024.
//

import Combine
import CoreBluetooth
import SwiftUI

struct DeviceStatusView: View {
    var peripheral: CBPeripheral

    @Binding var config: DeviceConfiguration
    @ObservedObject var currentLock: BluelockPeripheralDelegate
    @Binding var wantsConnection: Bool
    @State var allowLockUpdate: Bool = false

    @State var isConnected: Bool = false
    @State var update: Cancellable?

    var body: some View {
        Section("Status") {
            if !config.autoconnect {
                Button(action: { wantsConnection = !wantsConnection }) {
                    HStack {
                        Label(
                            title: {
                                Text(wantsConnection ? "Disconnect" : "Connect")
                            },
                            icon: {
                                Image(systemName: "link")
                                    .overlay {
                                        if wantsConnection {
                                            Image(systemName: "line.diagonal")
                                                .foregroundStyle(Color.red)
                                                .scaleEffect(1.5)
                                        }
                                    }
                            }
                        )
                        Spacer()
                    }
                }
            }

            if isConnected {
                if let lockState = currentLock.lockState {
                    HStack {
                        Label("Lock", systemImage: LockStateItem(state: lockState).getIconName())
                            .symbolRenderingMode(.hierarchical)
                        Spacer()
                        LockStateItem(state: lockState)
                            .foregroundStyle(allowLockUpdate ? Color.accentColor : Color.secondary)
                    }

                    HStack {
                        Label("Door", systemImage: DoorStateItem(state: lockState).getIconName())
                            .symbolRenderingMode(.hierarchical)
                        Spacer()
                        DoorStateItem(state: lockState)
                            .foregroundStyle(Color.secondary)
                    }
                } else {
                    Label(
                        title: {
                            Text("Loading")
                        },
                        icon: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                                .id(currentLock.rssi)
                                .scaleEffect(1.25)
                        }
                    )
                    .foregroundStyle(Color.accentColor)
                }
            } else if config.autoconnect || wantsConnection {
                Label(
                    title: {
                        Text("Connecting")
                    },
                    icon: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .id(currentLock.rssi)
                            .scaleEffect(1.25)
                    }
                )
            }
        }
        .onChange(of: config) {
            refreshAllowLockUpdate()
        }
        .onChange(of: currentLock.lockState?.closed) {
            refreshAllowLockUpdate()
        }
        .onAppear {
            self.update?.cancel()
            self.update = DispatchQueue.main.schedule(after: .init(.now()), interval: .milliseconds(250)) {
                isConnected = peripheral.state == .connected
            }
        }
        .onDisappear {
            self.update?.cancel()
        }
    }

    func refreshAllowLockUpdate() {
        var distanceConfig = false

        let distance = currentLock.distance()
        let great = LinkQuality(distance: distance) == .great
        switch (config.autolock, config.autounlock) {
        case (false, false):
            distanceConfig = true
        case (false, true):
            distanceConfig = !great
        case (true, false):
            distanceConfig = great
        case (true, true):
            distanceConfig = false
        }

        allowLockUpdate = distanceConfig || currentLock.lockState?.closed == false
    }
}
