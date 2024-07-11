//
//  DoorLockCombinedStateIcon.swift
//  Bluelock
//
//  Created by Matthew on 11/5/2024.
//  Copyright © 2024 thinkier.github.io. All rights reserved.
//

import SwiftUI

struct DoorLockCombinedStateIcon: View {
    var compact = true
    var state: DeviceReportedState
    var linkQuality = LinkQuality.great

    var body: some View {
        HStack {
            if compact {
                DoorStateItem(withText: false, state: state)
                    .foregroundStyle(.secondary)
                    .overlay(alignment: .leading) {
                        if state.closed {
                            LockStateItem(withText: false, state: state, linkQuality: linkQuality)
                                .foregroundStyle(Color.accentColor)
                                .scaleEffect(0.75)
                                .padding(.leading, 6)
                        }
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 10)
            } else {
                DoorStateItem(withText: false, state: state)
                    .foregroundStyle(.secondary)
                LockStateItem(withText: false, state: state, linkQuality: linkQuality)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .scaleEffect(1.25)
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: true, closed: true, disengaged: true))
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: false, closed: true, disengaged: true))
            Spacer()
        }
        Spacer()
        HStack {
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: true, closed: true, disengaged: false))
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: false, closed: true, disengaged: false))
            Spacer()
        }
        Spacer()
        HStack {
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: true, closed: false, disengaged: true))
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: false, closed: false, disengaged: true))
            Spacer()
        }
        Spacer()
        HStack {
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: true, closed: false, disengaged: false))
            Spacer()
            DoorLockCombinedStateIcon(state: DeviceReportedState(locked: false, closed: false, disengaged: false))
            Spacer()
        }
        Spacer()
    }
}
