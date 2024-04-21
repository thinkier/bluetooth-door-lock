import ProjectDescription

let project = Project(
    name: "Bluelock",
    organizationName: "thinkier.github.io",
    options: .options(xcodeProjectName: "Bluelock"),
    packages: [
        .remote(url: "https://github.com/stephencelis/SQLite.swift", requirement: .upToNextMajor(from: "0.15"))
    ],
    settings: .settings(base: SettingsDictionary()
        .automaticCodeSigning(devTeam: "6X8VAXGXBX")
    ),
    targets: [
        .target(
            name: "Bluelock",
            destinations: [.iPhone, .appleWatch],
            product: .app,
            productName: "Bluelock",
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
            entitlements: "Bluelock/Bluelock.entitlements",
            dependencies: []
        )
    ]
)
