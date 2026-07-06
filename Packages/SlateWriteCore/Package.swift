// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SlateWriteCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "SlateWriteCore", targets: ["SlateWriteCore"]),
    ],
    targets: [
        .target(
            name: "SlateWriteCore",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "SlateWriteCoreTests",
            dependencies: ["SlateWriteCore"]
        ),
    ]
)
