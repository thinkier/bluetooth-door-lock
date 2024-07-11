//
//  LockAttributes.swift
//  Bluelock
//
//  Created by Matthew on 11/5/2024.
//  Copyright © 2024 thinkier.github.io. All rights reserved.
//

import ActivityKit
import Foundation

struct LockAttributes: ActivityAttributes {
    struct ContentState: Codable & Hashable {
        let lockState: DeviceReportedState?
        let linkQuality: LinkQuality
        var lastUpdated = Date.now
    }

    let peer: UUID
    let name: String
}
