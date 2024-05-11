//
//  LockStateItem.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

struct LockStateItem: View {
    var withText: Bool = true
    var state: DeviceReportedState
    
    var body: some View {
        if state.disengaged {
            if state.locked {
                if withText {
                    Text("Locked")
                }
                Image(systemName: getIconName())
            } else {
                if withText {
                    Text("Unlocked")
                }
                Image(systemName: getIconName())
            }
        } else {
            if state.locked {
                if withText {
                    Text("Locked")
                }
                Image(systemName: getIconName() + ".fill")
            } else {
                if withText {
                    Text("Unlocked")
                }
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
