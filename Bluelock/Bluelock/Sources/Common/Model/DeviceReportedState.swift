//
//  DeviceReportedState.swift
//  Bluelock
//
//  Created by Matthew on 11/4/2024.
//

import Foundation

public struct DeviceReportedState: Codable, Hashable {
    var locked: Bool
    var closed: Bool
    var disengaged: Bool
}
