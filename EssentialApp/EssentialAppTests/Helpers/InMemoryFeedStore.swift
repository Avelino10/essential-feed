//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 23/02/2022.
//

import EssentialFeed
import Foundation
import Synchronization

/// Thread-safe like the production stores: responses from the async HTTP client
/// are cached from a background thread while the UI reads on the main thread.
final class InMemoryFeedStore: Sendable {
    private struct State {
        var feedCache: CachedFeed?
        var feedImageDataCache: [URL: Data] = [:]
    }

    private let state: Mutex<State>

    var feedCache: CachedFeed? {
        state.withLock { $0.feedCache }
    }

    private init(feedCache: CachedFeed? = nil) {
        state = Mutex(State(feedCache: feedCache))
    }
}

extension InMemoryFeedStore: FeedStore {
    func deleteCachedFeed() throws {
        state.withLock { $0.feedCache = nil }
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        state.withLock { $0.feedCache = CachedFeed(feed: feed, timestamp: timestamp) }
    }

    func retrieve() throws -> CachedFeed? {
        state.withLock { $0.feedCache }
    }
}

extension InMemoryFeedStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        state.withLock { $0.feedImageDataCache[url] = data }
    }

    func retrieve(dataForURL url: URL) throws -> Data? {
        state.withLock { $0.feedImageDataCache[url] }
    }
}

extension InMemoryFeedStore {
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }

    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date.distantPast))
    }

    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CachedFeed(feed: [], timestamp: Date()))
    }
}
