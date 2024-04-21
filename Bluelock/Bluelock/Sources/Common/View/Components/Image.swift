//
//  Image.swift
//  Bluelock
//
//  Created by Matthew on 20/4/2024.
//

import SwiftUI

extension Image {
    public func icon() -> some View {
        self.scaleEffect(1.5)
            .padding(.leading, 6)
            .padding(.trailing, 10)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
    }
}
