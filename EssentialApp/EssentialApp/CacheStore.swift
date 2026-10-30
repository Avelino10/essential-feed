//
//  CacheStore.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 30/10/2026.
//

import EssentialFeed
import Foundation

/// The store the app caches the feed in, chosen with the `-store` launch argument
/// (for example `-store swiftdata`). Core Data unless asked otherwise.
enum CacheStore: String, CaseIterable {
    case coreData = "coredata"
    case swiftData = "swiftdata"

    init(launchArguments: [String]) {
        guard let flag = launchArguments.firstIndex(of: "-store"),
              launchArguments.indices.contains(flag + 1),
              let store = CacheStore(rawValue: launchArguments[flag + 1].lowercased())
        else {
            self = .coreData
            return
        }

        self = store
    }

    /// Each store keeps its own file, so switching stores never opens the other's data.
    func make(in directory: URL) throws -> FeedStore & FeedImageDataStore {
        switch self {
            case .coreData:
                try CoreDataFeedStore(storeURL: directory.appendingPathComponent("feed-store.sqlite"))
            case .swiftData:
                try SwiftDataFeedStore(storeURL: directory.appendingPathComponent("feed-store-swiftdata.sqlite"))
        }
    }
}
