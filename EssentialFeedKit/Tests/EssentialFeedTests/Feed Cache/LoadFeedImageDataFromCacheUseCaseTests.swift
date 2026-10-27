//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct LoadFeedImageDataFromCacheUseCaseTests {
    @Test func `Init does not message store upon creation`() async {
        let (_, store) = makeSUT()

        #expect(store.receivedMessages.isEmpty)
    }

    @Test func `Load image data from URL requests stored data for URL`() async {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = try? await sut.loadImageData(from: url)

        #expect(store.receivedMessages == [.retrieve(dataFor: url)])
    }

    @Test func `Load image data fails on store error`() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: anyNSError())

        await #expect(throws: LocalFeedImageDataLoader.LoadError.failed) {
            try await sut.loadImageData(from: anyURL())
        }
    }

    @Test func `Load image data delivers not found error on not found`() async {
        let (sut, store) = makeSUT()
        store.completeRetrieval(with: .none)

        await #expect(throws: LocalFeedImageDataLoader.LoadError.notFound) {
            try await sut.loadImageData(from: anyURL())
        }
    }

    @Test func `Load image data delivers stored data on found data`() async throws {
        let (sut, store) = makeSUT()
        let foundData = anyData()
        store.completeRetrieval(with: foundData)

        let receivedData = try await sut.loadImageData(from: anyURL())

        #expect(receivedData == foundData)
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
