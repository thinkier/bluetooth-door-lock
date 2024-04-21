//
//  LockStateItem.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

struct LockStateItem: View {
    var state: DeviceReportedState
    
    var body: some View {
        if state.disengaged {
            if state.locked {
                Text("Locked")
                Image(systemName: getIconName())
            } else {
                Text("Unlocked")
                Image(systemName: getIconName())
            }
        } else {
            if state.locked {
                Text("Locked")
                Image(systemName: getIconName() + ".fill")
            } else {
                Text("Unlocked")
                Image(systemName: getIconName() + ".fill")
            }
        }
    }
    
    func getIconName() -> String {
        if state.locked {
            "lock"
        } else {
            "lock.open"
        }
    }
}
