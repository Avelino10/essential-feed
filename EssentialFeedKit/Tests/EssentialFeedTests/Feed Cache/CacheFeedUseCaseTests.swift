//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/07/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct CacheFeedUseCaseTests {
    @Test func `Init does not message store upon creation`() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages == [])
    }

    @Test func `Save does not request cache insertion on deletion error`() {
        let (sut, store) = makeSUT()
        store.completeDeletion(with: anyNSError())

        try? sut.save(uniqueImageFeed().models)

        #expect(store.receivedMessages == [.deleteCachedFeed])
    }

    @Test func `Save requests new cache insertion with timestamp on successful deletion`() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let feed = uniqueImageFeed()
        store.completeDeletionSuccessfully()

        try? sut.save(feed.models)

        #expect(store.receivedMessages == [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }

    @Test func `Save fails on deletion error`() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)

        #expect(throws: deletionError) {
            try sut.save(uniqueImageFeed().models)
        }
    }

    @Test func `Save fails on insertion error`() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        store.completeDeletionSuccessfully()
        store.completeInsertion(with: insertionError)

        #expect(throws: insertionError) {
            try sut.save(uniqueImageFeed().models)
        }
    }

    @Test func `Save succeeds on successful cache insertion`() {
        let (sut, store) = makeSUT()
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()

        #expect(throws: Never.self) {
            try sut.save(uniqueImageFeed().models)
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
