//
//  LinkQuality.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

public enum LinkQuality: Codable & Hashable & Comparable {
    /// Less than 1.25mm from the transmitter
    case great
    /// Less than 10m from the transmitter
    case good
    /// Greater than 10m from the transmitter
    case bad
    /// Out of range
    case none
    
    public init(distance: Float) {
        if distance <= 1.25 {
            self = .great
        } else if distance <= 10 {
            self = .good
        } else if distance <= 100 {
            self = .bad
        } else {
            self = .none
        }
    }
    
    public func iconName() -> String {
        switch self {
        case .great:
            return "wifi"
        case .good:
            return "wifi.exclamationmark"
        default:
            return "wifi.slash"
        }
    }
    
    public func color() -> Color {
        if self == .none {
            return .red
        } else {
            return .secondary
        }
    }
    
    static public func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.great, _):
            return true
        case (_, .great):
            return false
        case (.good, _):
            return true
        case (_, .good):
            return false
        case (.bad, _):
            return true
        default:
            return false
        }
    }
}
