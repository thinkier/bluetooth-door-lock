//
//  LockActivityConfiguration.swift
//  Bluelock
//
//  Created by Matthew on 11/5/2024.
//  Copyright © 2024 thinkier.github.io. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI
import CoreBluetooth


struct LockActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LockAttributes.self) { context in
            HStack {
                if context.state.lockState != nil {
                    DoorLockCombinedStateIcon(compact: false, state: context.state.lockState!)
                        .padding(.leading, 10)
                }
                Text(context.attributes.name)
                Spacer()
                LinkQualityIcon(Date.now.timeIntervalSince(context.state.lastUpdated) > 10 ? .none : context.state.linkQuality)
            }
            .padding(10)
        } dynamicIsland: { context in
            DynamicIsland(
                expanded: {
                    DynamicIslandExpandedRegion(.leading) {
                        if context.state.lockState != nil {
                            HStack {
                                DoorLockCombinedStateIcon(compact: false, state: context.state.lockState!)
                            }
                            .padding(.leading, 10)
                        }
                    }
                    DynamicIslandExpandedRegion(.center){
                        Text(context.attributes.name)
                    }
                    DynamicIslandExpandedRegion(.trailing) {
                        HStack {
                            LinkQualityIcon(context.state.linkQuality)
                        }
                        .padding(.trailing, 10)
                    }
                },
                compactLeading: {
                    if context.state.linkQuality != .none && context.state.lockState != nil {
                        DoorLockCombinedStateIcon(state: context.state.lockState!)
                    }
                },
                compactTrailing: {
                },
                minimal: {
                    if context.state.linkQuality != .none && context.state.lockState != nil {
                        DoorLockCombinedStateIcon(state: context.state.lockState!)
                    }
                }
            )
        }
    }
    
    public func create(peripheral: CBPeripheral, lockState: DeviceReportedState, linkQuality: LinkQuality) -> Activity<LockAttributes>? {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let lock = LockAttributes(peer: peripheral.identifier, name: peripheral.name ?? "Lock")
                let initialState = LockAttributes.ContentState(
                    lockState: lockState, linkQuality: linkQuality
                )
                
                return try Activity.request(
                    attributes: lock,
                    content: .init(state: initialState, staleDate: nil)
                )
            } catch {
                print(error)
            }
        }
        
        return nil
    }
}
