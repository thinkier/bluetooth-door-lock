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
    var linkQuality = LinkQuality.great

    var body: some View {
        if withText {
            Text(state.locked ? "Locked" : "Unlocked")
        }
        Image(systemName: getIconName())
            .symbolRenderingMode(.hierarchical)
    }

    func getIconName() -> String {
        var icon = "lock"
        if !state.locked {
            icon += ".open"
        } else if linkQuality == .none {
            icon += ".slash"
        }
        if !state.disengaged || linkQuality == .none {
            icon += ".fill"
        }

        return icon
    }
}
