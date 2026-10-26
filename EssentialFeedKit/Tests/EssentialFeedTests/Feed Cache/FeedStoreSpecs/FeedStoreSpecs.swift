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

func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore) throws {
    try expect(sut, toRetrieve: nil)
}

func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore) throws {
    try expect(sut, toRetrieveTwice: nil)
}

func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore) throws {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    try sut.insert(feed, timestamp: timestamp)

    try expect(sut, toRetrieve: (feed, timestamp))
}

func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore) throws {
    let feed = uniqueImageFeed().local
    let timestamp = Date()

    try sut.insert(feed, timestamp: timestamp)

    try expect(sut, toRetrieveTwice: (feed, timestamp))
}

func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
    #expect(throws: Never.self, "Expected to insert cache successfully") {
        try sut.insert(uniqueImageFeed().local, timestamp: Date())
    }
}

func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) throws {
    try sut.insert(uniqueImageFeed().local, timestamp: Date())

    #expect(throws: Never.self, "Expected to override cache successfully") {
        try sut.insert(uniqueImageFeed().local, timestamp: Date())
    }
}

func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore) throws {
    try sut.insert(uniqueImageFeed().local, timestamp: Date())

    let latestFeed = uniqueImageFeed().local
    let latestTimestamp = Date()
    try sut.insert(latestFeed, timestamp: latestTimestamp)

    try expect(sut, toRetrieve: (latestFeed, latestTimestamp))
}

func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
    #expect(throws: Never.self, "Expected empty cache deletion to succeed") {
        try sut.deleteCachedFeed()
    }
}

func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore) throws {
    try sut.deleteCachedFeed()

    try expect(sut, toRetrieve: nil)
}

func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) throws {
    try sut.insert(uniqueImageFeed().local, timestamp: Date())

    #expect(throws: Never.self, "Expected non-empty cache deletion to succeed") {
        try sut.deleteCachedFeed()
    }
}

func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore) throws {
    try sut.insert(uniqueImageFeed().local, timestamp: Date())

    try sut.deleteCachedFeed()

    try expect(sut, toRetrieve: nil)
}

// MARK: - Helpers

func expect(_ sut: FeedStore, toRetrieveTwice expectedCache: CachedFeed?) throws {
    try expect(sut, toRetrieve: expectedCache)
    try expect(sut, toRetrieve: expectedCache)
}

func expect(_ sut: FeedStore, toRetrieve expectedCache: CachedFeed?) throws {
    let retrievedCache = try sut.retrieve()

    #expect(retrievedCache?.feed == expectedCache?.feed)
    #expect(retrievedCache?.timestamp == expectedCache?.timestamp)
}
