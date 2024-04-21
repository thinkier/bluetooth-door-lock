//
//  DeviceConfiguration.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import Combine

public struct DeviceConfiguration: Codable, Hashable, Equatable {
    public var autoconnect: Bool
    public var autounlock: Bool
    public var autolock: Bool
    
    init() {
        self.init(autoconnect: false, autounlock: false, autolock: false)
    }
    
    init(autoconnect: Bool, autounlock: Bool, autolock: Bool) {
        self.autoconnect = autoconnect
        self.autounlock = autounlock
        self.autolock = autolock
    }
}
