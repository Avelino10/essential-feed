//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 19/07/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct ValidateFeedCacheUseCaseTests {
    @Test func `Init does not message store upon creation`() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    @Test func `Validate cache deletes cache on retrieval error`() {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())

        try? sut.validateCache()

        #expect(store.receivedMessages == [.retrieve, .deleteCachedFeed])
    }

    @Test func `Validate cache does not delete cache on empty cache`() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        try? sut.validateCache()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Validate cache does not delete non-expired cache`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        try? sut.validateCache()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Validate cache deletes cache on expiration`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        try? sut.validateCache()

        #expect(store.receivedMessages == [.retrieve, .deleteCachedFeed])
    }

    @Test func `Validate cache deletes expired cache`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        try? sut.validateCache()

        #expect(store.receivedMessages == [.retrieve, .deleteCachedFeed])
    }

    @Test func `Validate cache fails on deletion error of failed retrieval`() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeRetrieval(with: anyNSError())
        store.completeDeletion(with: deletionError)

        #expect(throws: deletionError) {
            try sut.validateCache()
        }
    }

    @Test func `Validate cache succeeds on successful deletion of failed retrieval`() {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())
        store.completeDeletionSuccessfully()

        #expect(throws: Never.self) {
            try sut.validateCache()
        }
    }

    @Test func `Validate cache succeeds on empty cache`() {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        #expect(throws: Never.self) {
            try sut.validateCache()
        }
    }

    @Test func `Validate cache succeeds on non-expired cache`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        #expect(throws: Never.self) {
            try sut.validateCache()
        }
    }

    @Test func `Validate cache fails on deletion error of expired cache`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        store.completeDeletion(with: deletionError)

        #expect(throws: deletionError) {
            try sut.validateCache()
        }
    }

    @Test func `Validate cache succeeds on successful deletion of expired cache`() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        store.completeDeletionSuccessfully()

        #expect(throws: Never.self) {
            try sut.validateCache()
        }
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}
