//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 10/07/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct LoadFeedFromCacheUseCaseTests {
    @Test func `Init does not message store upon creation`() async {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    @Test func `Load requests cache retrieval`() async {
        let (sut, store) = makeSUT()

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Load fails on retrieval error`() async {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        store.completeRetrieval(with: retrievalError)

        await #expect(throws: retrievalError) {
            try await sut.load()
        }
    }

    @Test func `Load delivers no images on empty cache`() async throws {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        let images = try await sut.load()

        #expect(images == [])
    }

    @Test func `Load delivers cached images on non-expired cache`() async throws {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        let images = try await sut.load()

        #expect(images == feed.models)
    }

    @Test func `Load delivers no images on cache expiration`() async throws {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        let images = try await sut.load()

        #expect(images == [])
    }

    @Test func `Load delivers no images on expired cache`() async throws {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        let images = try await sut.load()

        #expect(images == [])
    }

    @Test func `Load has no side effects on retrieval error`() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Load has no side effects on empty cache`() async {
        let (sut, store) = makeSUT()
        store.completeRetrievalWithEmptyCache()

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Load has no side effects on non-expired cache`() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Load has no side effects on cache expiration`() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
    }

    @Test func `Load has no side effects on expired cache`() async {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)

        _ = try? await sut.load()

        #expect(store.receivedMessages == [.retrieve])
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
