import ProjectDescription

let project = Project(
    name: "Bluelock",
    targets: [
        .target(
            name: "Bluelock",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Bluelock",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
                ]
            ),
            sources: ["Bluelock/Sources/**"],
            resources: ["Bluelock/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "BluelockTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.BluelockTests",
            infoPlist: .default,
            sources: ["Bluelock/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Bluelock")]
        ),
    ]
)
