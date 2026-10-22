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
    ],
    targets: [
        .target(
            name: "EssentialFeed",
            exclude: ["Info.plist"]
        ),
        .target(
            name: "EssentialFeediOS",
            dependencies: ["EssentialFeed"],
            exclude: ["Info.plist"]
        ),
        .target(
            name: "EssentialFeedTestHelpers",
            dependencies: ["EssentialFeed"],
            path: "Tests/EssentialFeedTestHelpers"
        ),
        .testTarget(
            name: "EssentialFeedTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "EssentialFeedCacheIntegrationTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "EssentialFeedAPIEndToEndTests",
            dependencies: ["EssentialFeed", "EssentialFeedTestHelpers"],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "EssentialFeediOSTests",
            dependencies: ["EssentialFeed", "EssentialFeediOS"],
            exclude: ["Info.plist", "Feed UI/snapshots", "Image Comments UI/snapshots", "Shared UI/snapshots"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
