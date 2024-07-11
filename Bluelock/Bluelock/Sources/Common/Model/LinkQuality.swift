//
//  LinkQuality.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

public enum LinkQuality: Codable & Hashable & Comparable {
    /// Less than 1m from the transmitter
    case great
    /// Less than 8m from the transmitter
    case good
    /// Greater than 16m from the transmitter
    case bad
    /// Out of range
    case none

    public init(distance: Float) {
        if distance <= 1 {
            self = .great
        } else if distance <= 8 {
            self = .good
        } else if distance <= 16 {
            self = .bad
        } else {
            self = .none
        }
    }

    public func color() -> Color {
        switch self {
        case .great:
            return .green
        case .good:
            return .yellow
        case .bad:
            return .red
        default:
            return .secondary
        }
    }

    public func score() -> Double {
        switch self {
        case .great:
            return 1
        case .good:
            return 2 / 3
        case .bad:
            return 1 / 3
        default:
            return 0
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        return rhs.score() < lhs.score()
    }
}
