import ProjectDescription

let project = Project(
    name: "Bluelock",
    organizationName: "thinkier.github.io",
    packages: [
        .remote(url: "https://github.com/stephencelis/SQLite.swift", requirement: .upToNextMajor(from: "0.15"))
    ],
    targets: [
        .target(
            name: "Bluelock",
            destinations: [.iPhone, .appleWatch],
            product: .app,
            bundleId: "io.github.thinkier.Bluelock",
            deploymentTargets: .multiplatform(iOS: "16.0", watchOS: "9.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                    "NSUserNotificationsUsageDescription": "Recieve alerts when the lock is actuated automatically.",
                    "UIBackgroundModes": ["bluetooth-central"],
                    "UIFileSharingEnabled": true,
                    "LSSupportsOpeningDocumentsInPlace": true
                ]
            ),
            sources: ["Bluelock/Sources/**"],
            resources: ["Bluelock/Resources/**"],
            dependencies: [
                .package(product: "SQLite.swift", type: .runtime)
            ]
        )
    ]
)
