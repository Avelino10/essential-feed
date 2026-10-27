//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

// The behavior every `FeedStore` implementation must have.
// Each store's test suite calls every spec below with a fresh, empty store.

func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore) async throws {
    try await expect(sut, toRetrieve: nil)
}

func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore) async throws {
    try await expect(sut, toRetrieveTwice: nil)
}

func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore) async throws {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    try await sut.insert(feed, timestamp: timestamp)

    try await expect(sut, toRetrieve: (feed, timestamp))
}

func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore) async throws {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    try await sut.insert(feed, timestamp: timestamp)

    try await expect(sut, toRetrieveTwice: (feed, timestamp))
}

func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore) async {
    await #expect(throws: Never.self, "Expected to insert cache successfully") {
        try await sut.insert(uniqueImageFeed().local, timestamp: Date())
    }
}

func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) async throws {
    try await sut.insert(uniqueImageFeed().local, timestamp: Date())

    await #expect(throws: Never.self, "Expected to override cache successfully") {
        try await sut.insert(uniqueImageFeed().local, timestamp: Date())
    }
}

func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore) async throws {
    try await sut.insert(uniqueImageFeed().local, timestamp: Date())

    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    try await sut.insert(latestFeed, timestamp: latestTimestamp)

    try await expect(sut, toRetrieve: (latestFeed, latestTimestamp))
}

func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore) async {
    await #expect(throws: Never.self, "Expected empty cache deletion to succeed") {
        try await sut.deleteCachedFeed()
    }
}

func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore) async throws {
    try await sut.deleteCachedFeed()

    try await expect(sut, toRetrieve: nil)
}

func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) async throws {
    try await sut.insert(uniqueImageFeed().local, timestamp: Date())

    await #expect(throws: Never.self, "Expected non-empty cache deletion to succeed") {
        try await sut.deleteCachedFeed()
    }
}

func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore) async throws {
    try await sut.insert(uniqueImageFeed().local, timestamp: Date())

    try await sut.deleteCachedFeed()

    try await expect(sut, toRetrieve: nil)
}

// MARK: - Helpers

func expect(_ sut: FeedStore, toRetrieveTwice expectedCache: CachedFeed?) async throws {
    try await expect(sut, toRetrieve: expectedCache)
    try await expect(sut, toRetrieve: expectedCache)
}

func expect(_ sut: FeedStore, toRetrieve expectedCache: CachedFeed?) async throws {
    let retrievedCache = try await sut.retrieve()

    #expect(retrievedCache?.feed == expectedCache?.feed)
    #expect(retrievedCache?.timestamp == expectedCache?.timestamp)
}
