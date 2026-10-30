//
//  SwiftDataFeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/10/2026.
//

import Foundation
import SwiftData

/// A feed store backed by SwiftData. Models never leave the actor: it only hands out values.
@ModelActor
public actor SwiftDataFeedStore {
    /// Image data lives on the cached images, and saving a feed deletes the old one first.
    /// Keeping the deleted images' data until the next insert lets images still in the new feed keep it.
    private var deletedImageData = [URL: Data]()
}

extension SwiftDataFeedStore {
    public init(storeURL: URL) throws {
        let container = try ModelContainer(
            for: SwiftDataFeedCache.self, SwiftDataFeedImage.self,
            configurations: ModelConfiguration(url: storeURL))
        self.init(modelContainer: container)
    }
}

extension SwiftDataFeedStore: FeedStore {
    public func retrieve() throws -> CachedFeed? {
        try caches().first.map { CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp) }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try deleteCaches()

        let images = feed.enumerated().map { position, local in
            let image = SwiftDataFeedImage(local, position: position)
            image.data = deletedImageData[local.url]
            return image
        }
        deletedImageData = [:]
        modelContext.insert(SwiftDataFeedCache(timestamp: timestamp, feed: images))

        try modelContext.save()
    }

    public func deleteCachedFeed() throws {
        try deleteCaches()
        try modelContext.save()
    }

    private func caches() throws -> [SwiftDataFeedCache] {
        try modelContext.fetch(FetchDescriptor<SwiftDataFeedCache>())
    }

    private func deleteCaches() throws {
        for cache in try caches() {
            for image in cache.feed {
                if let data = image.data { deletedImageData[image.url] = data }
            }
            modelContext.delete(cache)
        }
    }
}
