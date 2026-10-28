//
//  SwiftDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 28/10/2026.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct SwiftDataFeedImageDataStoreTests {
    @Test func `Retrieve image data delivers not found when empty`() async throws {
        let sut = try makeSUT()

        let receivedData = try await sut.retrieve(dataForURL: anyURL())

        #expect(receivedData == nil)
    }

    @Test func `Retrieve image data delivers not found when stored data URL does not match`() async throws {
        let sut = try makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!

        try await insert(anyData(), for: url, into: sut)

        let receivedData = try await sut.retrieve(dataForURL: nonMatchingURL)
        #expect(receivedData == nil)
    }

    @Test func `Retrieve image data delivers found data when there is stored image data matching URL`() async throws {
        let sut = try makeSUT()
        let storedData = anyData()
        let matchingURL = URL(string: "http://a-url.com")!

        try await insert(storedData, for: matchingURL, into: sut)

        let receivedData = try await sut.retrieve(dataForURL: matchingURL)
        #expect(receivedData == storedData)
    }

    @Test func `Retrieve image data delivers last inserted value`() async throws {
        let sut = try makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let matchingURL = URL(string: "http://a-url.com")!

        try await insert(firstStoredData, for: matchingURL, into: sut)
        try await insert(lastStoredData, for: matchingURL, into: sut)

        let receivedData = try await sut.retrieve(dataForURL: matchingURL)
        #expect(receivedData == lastStoredData)
    }

    // MARK: - Helpers

    private func makeSUT() throws -> FeedStore & FeedImageDataStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try SwiftDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }

    private func localImage(url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }

    private func insert(_ data: Data, for url: URL, into sut: FeedStore & FeedImageDataStore) async throws {
        let image = localImage(url: url)
        try await sut.insert([image], timestamp: Date())
        try await sut.insert(data, for: url)
    }
}
