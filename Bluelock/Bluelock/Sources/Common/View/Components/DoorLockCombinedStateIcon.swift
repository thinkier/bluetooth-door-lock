//
//  DoorLockCombinedStateIcon.swift
//  Bluelock
//
//  Created by Matthew on 11/5/2024.
//  Copyright © 2024 thinkier.github.io. All rights reserved.
//

import SwiftUI

struct DoorLockCombinedStateIcon: View {
    var state: DeviceReportedState
    
    var body: some View {
        ZStack(alignment: .center) {
            DoorStateItem(withText: false, state: state)
                .foregroundStyle(.secondary)
            if state.closed {
                LockStateItem(withText: false, state: state)
                    .foregroundStyle(Color.accentColor)
                    .scaleEffect(0.75)
                    .padding(.leading, 16)
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
        DoorLockCombinedStateIcon(state: DeviceReportedState(locked: true, closed: false, disengaged: true))
        Spacer()
    }
}
