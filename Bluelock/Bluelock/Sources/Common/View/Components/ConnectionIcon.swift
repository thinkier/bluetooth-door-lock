//
//  ConnectionIcon.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

struct ConnectionIcon: View {
    var isAutoConnect: Bool?
    var isConnected: Bool

    var body: some View {
        if isAutoConnect == true {
            Image(systemName: "wave.3.left")
                .symbolRenderingMode(.hierarchical)
                .symbolEffect(.variableColor, isActive: true)
                .foregroundStyle(isConnected == true ? Color.green : Color.secondary)
        }
        if isConnected {
            Image(systemName: "link")
                .foregroundStyle(Color.accentColor)
        }
    }
}
