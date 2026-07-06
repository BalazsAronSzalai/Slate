// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "SlateCore",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18), .macOS(.v15), .watchOS(.v11) // bump to 26 SDKs when building against release Xcode 26
    ],
    products: [
        .library(name: "SlateCore", targets: ["SlateCore"])
    ],
    targets: [
        .target(
            name: "SlateCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags(["-warnings-as-errors"], .when(configuration: .release))
            ]
        ),
        .testTarget(
            name: "SlateCoreTests",
            dependencies: ["SlateCore"]
        )
    ]
)
