//
//  LinkQuality.swift
//  Bluelock
//
//  Created by Matthew on 10/4/2024.
//

import SwiftUI

struct LinkQualityIcon: View {
    var linkQuality: LinkQuality
    
    init(_ linkQuality: LinkQuality) {
        self.linkQuality = linkQuality
    }
    
    init(rssi: Float, txPower: Float) {
        self.init(LinkQuality(distance: estimateDistance(rssi: rssi, txPower: txPower)))
    }
    
    var body: some View {
        Image(systemName: linkQuality.iconName())
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(linkQuality.color())
    }
}
