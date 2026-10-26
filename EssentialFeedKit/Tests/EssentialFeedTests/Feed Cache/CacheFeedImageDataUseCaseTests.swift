//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct CacheFeedImageDataUseCaseTests {
    @Test func `Init does not message store upon creation`() {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages.isEmpty)
    }

    @Test func `Save image data for URL requests image data insertion for URL`() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()

        try? sut.save(data, for: url)

        #expect(store.receivedMessages == [.insert(data: data, for: url)])
    }

    @Test func `Save image data fails on store insertion error`() {
        let (sut, store) = makeSUT()
        store.completeInsertion(with: anyNSError())

        #expect(throws: LocalFeedImageDataLoader.SaveError.failed) {
            try sut.save(anyData(), for: anyURL())
        }
    }

    @Test func `Save image data succeeds on successful store insertion`() {
        let (sut, store) = makeSUT()
        store.completeInsertionSuccessfully()

        #expect(throws: Never.self) {
            try sut.save(anyData(), for: anyURL())
        }
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return (sut, store)
    }
}
