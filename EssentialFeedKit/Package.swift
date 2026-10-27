// swift-tools-version: 6.2

import PackageDescription

/// Nonisolated async functions run on the caller's actor, as in new Xcode projects,
/// instead of always hopping to the global executor.
let approachableConcurrency: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]

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
            swiftSettings: approachableConcurrency
        ),
        .target(
            name: "EssentialFeediOS",
            dependencies: ["EssentialFeed"],
            swiftSettings: approachableConcurrency + [.defaultIsolation(MainActor.self)]
        ),
        .target(
            name: "EssentialFeedTestHelpers",
            dependencies: ["EssentialFeed"],
            path: "Tests/EssentialFeedTestHelpers",
            swiftSettings: approachableConcurrency
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: approachableConcurrency
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: approachableConcurrency
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            swiftSettings: approachableConcurrency
        ),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: ["EssentialFeed", "EssentialFeediOS"],
            exclude: ["Feed UI/snapshots", "Image Comments UI/snapshots", "Shared UI/snapshots"],
            swiftSettings: approachableConcurrency
        ),
    ],
    swiftLanguageModes: [.v6]
)
