//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 05/07/2021.
//

import Foundation

public final class LocalFeedLoader: Sendable {
    private let store: FeedStore
    private let currentDate: @Sendable () -> Date

    public init(store: FeedStore, currentDate: @escaping @Sendable () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) async throws {
        try await store.deleteCachedFeed()
        try await store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    public func load() async throws -> [FeedImage] {
        if let cache = try await store.retrieve(), FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
            return cache.feed.toModels()
        }

        return []
    }
}

extension LocalFeedLoader {
    private struct InvalidCache: Error {}

    public func validateCache() async throws {
        do {
            if let cache = try await store.retrieve(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try await store.deleteCachedFeed()
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
