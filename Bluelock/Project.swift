import ProjectDescription

let project = Project(
    name: "Bluelock",
    targets: [
        .target(
            name: "Bluelock",
            destinations: .iOS,
            product: .app,
            bundleId: "io.github.thinkier.Bluelock",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Bluelock/Sources/**"],
            resources: ["Bluelock/Resources/**"],
            dependencies: [.package(url: "https://github.com/stephencelis/SQLite.swift", from: "0.15.0")]
        )
    ]
)
