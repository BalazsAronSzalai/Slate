// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SlateWriteCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18), .macOS(.v15), .watchOS(.v11)
    ],
    products: [
        .library(name: "SlateWriteCore", targets: ["SlateWriteCore"])
    ],
    dependencies: [
        .package(path: "../SlateCore")
    ],
    targets: [
        .target(
            name: "SlateWriteCore",
            dependencies: ["SlateCore"],
            resources: [
                .copy("Resources/Fixtures")
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SlateWriteCoreTests",
            dependencies: ["SlateWriteCore"]
        )
    ]
)
