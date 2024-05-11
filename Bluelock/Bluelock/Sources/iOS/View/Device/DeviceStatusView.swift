//
//  DeviceStatusView.swift
//  Bluelock
//
//  Created by Matthew on 13/4/2024.
//

import SwiftUI
import CoreBluetooth
import Combine

struct DeviceStatusView: View {
    var peripheral: CBPeripheral
    
    @Binding var config: DeviceConfiguration
    @ObservedObject var currentLock: BluelockPeripheralDelegate
    @Binding var wantsConnection: Bool
    @State var allowLockUpdate: Bool = false
    
    @State var isConnected: Bool = false;
    @State var update: Cancellable?;
    
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
                        Menu {
                            Button {
                                currentLock.setState(peripheral, locked: true)
                            } label: {
                                LockStateItem(state: DeviceReportedState(locked: true, closed: false, disengaged: false))
                            }
                            Button {
                                currentLock.setState(peripheral, locked: false)
                            } label: {
                                LockStateItem(state: DeviceReportedState(locked: false, closed: false, disengaged: false))
                            }
                        } label: {
                            LockStateItem(state: lockState)
                        }
                        .disabled(!allowLockUpdate)
                        .foregroundStyle(allowLockUpdate ? Color.accentColor : Color.secondary)
                    }
                    
                    HStack {
                        Label("Door", systemImage: DoorStateItem(state: lockState).getIconName())
                            .symbolRenderingMode(.hierarchical)
                        Spacer()
                        DoorStateItem(state: lockState)
                            .foregroundStyle(Color.secondary)
                    }
                    
                    HStack {
                        Button("Activity", systemImage: "iphone.gen3", action: {
                            if currentLock.activity == nil {
                                currentLock.activity = LockActivityConfiguration()
                                    .create(
                                        peripheral: peripheral,
                                        lockState: lockState,
                                        linkQuality: LinkQuality(distance: currentLock.distance())
                                    )
                            }
                        })
                        .symbolRenderingMode(.hierarchical)
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
        var distanceConfig = false;
        
        let distance = currentLock.distance()
        let great = LinkQuality(distance: distance) == .great
        switch (config.autolock, config.autounlock) {
        case (false, false):
            distanceConfig = true
            break
        case (false, true):
            distanceConfig = !great
            break
        case (true, false):
            distanceConfig = great
            break
        case (true, true):
            distanceConfig = false
            break
        }
        
        allowLockUpdate = distanceConfig || currentLock.lockState?.closed == false
    }
}
