//
//  Image.swift
//  Bluelock
//
//  Created by Matthew on 20/4/2024.
//

import SwiftUI

public extension Image {
    func icon() -> some View {
        scaleEffect(1.5)
            .padding(.leading, 6)
            .padding(.trailing, 10)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
    }
}
