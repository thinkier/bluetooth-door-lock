//
//  LinkQualityIcon.swift
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
        Image(systemName: "chart.bar\(linkQuality == .none ? "" : ".fill")")
            .foregroundStyle(linkQuality.color())
            .symbolRenderingMode(.hierarchical)
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            LinkQualityIcon(.great)
            Spacer()
            LinkQualityIcon(.good)
            Spacer()
        }
        Spacer()
        HStack {
            Spacer()
            LinkQualityIcon(.bad)
            Spacer()
            LinkQualityIcon(.none)
            Spacer()
        }
        Spacer()
    }
}
