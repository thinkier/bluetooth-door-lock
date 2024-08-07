import ProjectDescription

let project = Project(
    name: "Bluelock",
    organizationName: "thinkier.github.io",
    options: .options(xcodeProjectName: "Bluelock"),
    packages: [
        .remote(url: "https://github.com/stephencelis/SQLite.swift", requirement: .upToNextMajor(from: "0.15")),
    ],
    settings: .settings(base: SettingsDictionary()
        .automaticCodeSigning(devTeam: "6X8VAXGXBX")
    ),
    targets: [
        .target(
            name: "Bluelock iOS",
            destinations: .iOS,
            product: .app,
            productName: "Bluelock",
            bundleId: "io.github.thinkier.Bluelock",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "NSUserNotificationsUsageDescription": "Recieve alerts when the lock is actuated automatically.",
                    "NSBluetoothAlwaysUsageDescription": "Connect to Smart Locks.",
                    "NSSupportsLiveActivities": true,
                    "UIBackgroundModes": ["bluetooth-central"],
                    "UIFileSharingEnabled": true,
                    "LSSupportsOpeningDocumentsInPlace": true,
                ]
            ),
            sources: ["Bluelock/Sources/Common/**", "Bluelock/Sources/iOS/**", "Bluelock/Sources/App/**"],
            resources: ["Bluelock/Resources/Common/**", "Bluelock/Resources/iOS/**"],
            entitlements: "Bluelock/Bluelock.entitlements",
            dependencies: [.package(product: "SQLite", type: .runtime), .target(name: "Bluelock Widgets")]
        ),
        .target(
            name: "Bluelock Widgets",
            destinations: .iOS,
            product: .appExtension,
            productName: "BluelockWidgets",
            bundleId: "io.github.thinkier.Bluelock.widgets",
            infoPlist: .extendingDefault(
                with: [
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                    ],
                ]
            ),
            sources: ["Bluelock/Sources/Common/**", "Bluelock/Sources/iOS/**", "Bluelock/Sources/Widgets/**"],
            resources: ["Bluelock/Resources/Common/**", "Bluelock/Resources/iOS/**"],
            dependencies: [.package(product: "SQLite", type: .runtime)]
        ),
        .target(
            name: "Bluelock watchOS",
            destinations: .watchOS,
            product: .app,
            productName: "Bluelock",
            bundleId: "io.github.thinkier.Bluelock.watchos",
            deploymentTargets: .watchOS("10.0"),
            infoPlist: .extendingDefault(
                with: [
                    "NSUserNotificationsUsageDescription": "Recieve alerts when the lock is actuated automatically.",
                    "NSBluetoothAlwaysUsageDescription": "Connect to Smart Locks.",
                    "WKApplication": true,
                    "WKAppBundleIdentifier": "io.github.thinkier.Bluelock.watchos",
                    "WKCompanionAppBundleIdentifier": "io.github.thinkier.Bluelock",
                    "WKRunsIndependentlyOfCompanionApp": true,
                    "UIFileSharingEnabled": true,
                    "LSSupportsOpeningDocumentsInPlace": true,
                ]
            ),
            sources: ["Bluelock/Sources/Common/**", "Bluelock/Sources/watchOS/**", "Bluelock/Sources/App/**"],
            resources: ["Bluelock/Resources/Common/**"],
            entitlements: "Bluelock/Bluelock.entitlements",
            dependencies: [.package(product: "SQLite", type: .runtime)]
        ),
    ]
)
