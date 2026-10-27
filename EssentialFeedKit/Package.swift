// swift-tools-version: 6.2

import PackageDescription

/// Targets migrated to Swift 6 language mode.
let swift6: [SwiftSetting] = [.swiftLanguageMode(.v6)]

let package = Package(
    name: "EssentialFeedKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "EssentialFeed", targets: ["EssentialFeed"]),
        .library(name: "EssentialFeediOS", targets: ["EssentialFeediOS"]),
        .library(name: "EssentialFeedTestHelpers", targets: ["EssentialFeedTestHelpers"]),
    ],
    targets: [
        .target(
            name: "EssentialFeed",
            swiftSettings: swift6
        ),
        .target(
            name: "EssentialFeediOS",
            dependencies: ["EssentialFeed"]
        ),
        .target(
            name: "EssentialFeedTestHelpers",
            dependencies: ["EssentialFeed"],
            path: "Tests/EssentialFeedTestHelpers",
            swiftSettings: swift6
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: swift6
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: swift6
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: swift6
        ),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: ["EssentialFeed", "EssentialFeediOS"],
            exclude: ["Feed UI/snapshots", "Image Comments UI/snapshots", "Shared UI/snapshots"]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// Complete concurrency checking as warnings for the targets still in Swift 5 mode.
for target in package.targets where target.swiftSettings == nil {
    target.swiftSettings = [.enableUpcomingFeature("StrictConcurrency")]
}
