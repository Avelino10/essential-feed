//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Avelino Rodrigues on 03/08/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

// A class, so `deinit` can delete the on-disk store after each test.
// Every test gets its own store directory, so the tests can run in parallel.
@Suite(.trackingMemoryLeaks)
final class EssentialFeedCacheIntegrationTests {
    private let storeDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(EssentialFeedCacheIntegrationTests.self)-\(UUID().uuidString)", isDirectory: true)

    init() throws {
        try FileManager.default.createDirectory(at: storeDirectory, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: storeDirectory)
    }

    // MARK: - LocalFeedLoader Tests

    @Test func `Load delivers no items on empty cache`() async throws {
        let feedLoader = try makeFeedLoader()

        #expect(try await feedLoader.load() == [])
    }

    @Test func `Load delivers items saved on a separate instance`() async throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)

        #expect(try await feedLoaderToPerformLoad.load() == feed)
    }

    @Test func `Save overrides items saved on a separate instance`() async throws {
        let feedLoaderToPerformFirstSave = try makeFeedLoader()
        let feedLoaderToPerformLastSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        try await feedLoaderToPerformFirstSave.save(firstFeed)
        try await feedLoaderToPerformLastSave.save(latestFeed)

        #expect(try await feedLoaderToPerformLoad.load() == latestFeed)
    }

    @Test func `Validate feed cache does not delete recently saved feed`() async throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerformValidation = try makeFeedLoader()
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)
        try await feedLoaderToPerformValidation.validateCache()

        #expect(try await feedLoaderToPerformSave.load() == feed)
    }

    @Test func `Validate feed cache deletes feed saved in a distant past`() async throws {
        let feedLoaderToPerformSave = try makeFeedLoader(currentDate: .distantPast)
        let feedLoaderToPerformValidation = try makeFeedLoader(currentDate: Date())
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)
        try await feedLoaderToPerformValidation.validateCache()

        #expect(try await feedLoaderToPerformSave.load() == [])
    }

    // MARK: - LocalFeedImageDataLoader Tests

    @Test func `Load image data delivers saved data on a separate instance`() async throws {
        let imageLoaderToPerformSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()

        try await feedLoader.save([image])
        try imageLoaderToPerformSave.save(dataToSave, for: image.url)

        #expect(try imageLoaderToPerformLoad.loadImageData(from: image.url) == dataToSave)
    }

    @Test func `Save image data overrides saved image data on a separate instance`() async throws {
        let imageLoaderToPerformFirstSave = try makeImageLoader()
        let imageLoaderToPerformLastSave = try makeImageLoader()
        let imageLoaderToPerformLoad = try makeImageLoader()
        let feedLoader = try makeFeedLoader()
        let image = uniqueImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)

        try await feedLoader.save([image])
        try imageLoaderToPerformFirstSave.save(firstImageData, for: image.url)
        try imageLoaderToPerformLastSave.save(lastImageData, for: image.url)

        #expect(try imageLoaderToPerformLoad.loadImageData(from: image.url) == lastImageData)
    }

    // MARK: - Helpers

    private func makeFeedLoader(currentDate: Date = Date()) throws -> LocalFeedLoader {
        let store = try CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)

        return sut
    }

    private func makeImageLoader() throws -> LocalFeedImageDataLoader {
        let store = try CoreDataFeedStore(storeURL: testSpecificStoreURL())
        let sut = LocalFeedImageDataLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)

        return sut
    }

    private func testSpecificStoreURL() -> URL {
        storeDirectory.appendingPathComponent("feed.store")
    }
}
