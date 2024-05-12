//
//  BluelockApp.swift
//  Bluelock
//
//  Created by Matthew on 8/4/2024.
//

#if canImport(ActivityKit)
import ActivityKit
#endif
import SwiftUI
import UIKit
import UserNotifications

@main
struct BluelockApp: App {
    @StateObject var blueCentral = BluelockCentralDelegate()
    
    var body: some Scene {
        WindowGroup {
            DevicesView(blueCentral: blueCentral)
                .onAppear {
                    let notif = UNUserNotificationCenter.current()
                    notif.getNotificationSettings() {
                        if $0.alertSetting != .enabled || $0.criticalAlertSetting != .enabled {
                            Task {
                                try await notif.requestAuthorization(options: [.alert, .sound, .criticalAlert])
                            }
                        }
                    }
                }
        }
    }
}
