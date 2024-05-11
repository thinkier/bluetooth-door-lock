//
//  DoorStateItem.swift
//  Bluelock
//
//  Created by Matthew on 13/4/2024.
//

import SwiftUI

struct DoorStateItem: View {
    var withText: Bool = true
    var state: DeviceReportedState?
    
    var body: some View {
        if state?.closed == true {
            if withText {
                Text("Closed")
            }
            Image(systemName: getIconName())
                .symbolRenderingMode(.hierarchical)
        } else {
            if withText {
                Text("Open")
            }
            Image(systemName: getIconName())
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    func getIconName() -> String {
        if state?.closed == true {
            "door.left.hand.closed"
        } else {
            "door.left.hand.open"
        }
    }
}

#Preview {
    DoorStateItem()
}
