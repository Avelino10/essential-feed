// swift-tools-version: 6.2

import PackageDescription

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
        .target(name: "EssentialFeed"),
        .target(
            name: "EssentialFeediOS",
            dependencies: ["EssentialFeed"]
        ),
        .target(
            name: "EssentialFeedTestHelpers",
            dependencies: ["EssentialFeed"],
            path: "Tests/EssentialFeedTestHelpers"
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"]
        ),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: ["EssentialFeed", "EssentialFeediOS"],
            exclude: ["Feed UI/snapshots", "Image Comments UI/snapshots", "Shared UI/snapshots"]
        ),
    ],
    swiftLanguageModes: [.v5]
)

// Complete concurrency checking as warnings while the targets are still in Swift 5 mode.
for target in package.targets {
    target.swiftSettings = (target.swiftSettings ?? []) + [.enableUpcomingFeature("StrictConcurrency")]
}
