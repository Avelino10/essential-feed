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

    @Test(arguments: Store.allCases) func `Load delivers no items on empty cache`(store: Store) async throws {
        let feedLoader = try makeFeedLoader(store)

        #expect(try await feedLoader.load() == [])
    }

    @Test(arguments: Store.allCases) func `Load delivers items saved on a separate instance`(store: Store) async throws {
        let feedLoaderToPerformSave = try makeFeedLoader(store)
        let feedLoaderToPerformLoad = try makeFeedLoader(store)
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)

        #expect(try await feedLoaderToPerformLoad.load() == feed)
    }

    @Test(arguments: Store.allCases) func `Save overrides items saved on a separate instance`(store: Store) async throws {
        let feedLoaderToPerformFirstSave = try makeFeedLoader(store)
        let feedLoaderToPerformLastSave = try makeFeedLoader(store)
        let feedLoaderToPerformLoad = try makeFeedLoader(store)
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models

        try await feedLoaderToPerformFirstSave.save(firstFeed)
        try await feedLoaderToPerformLastSave.save(latestFeed)

        #expect(try await feedLoaderToPerformLoad.load() == latestFeed)
    }

    @Test(arguments: Store.allCases) func `Validate feed cache does not delete recently saved feed`(store: Store) async throws {
        let feedLoaderToPerformSave = try makeFeedLoader(store)
        let feedLoaderToPerformValidation = try makeFeedLoader(store)
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)
        try await feedLoaderToPerformValidation.validateCache()

        #expect(try await feedLoaderToPerformSave.load() == feed)
    }

    @Test(arguments: Store.allCases) func `Validate feed cache deletes feed saved in a distant past`(store: Store) async throws {
        let feedLoaderToPerformSave = try makeFeedLoader(store, currentDate: .distantPast)
        let feedLoaderToPerformValidation = try makeFeedLoader(store, currentDate: Date())
        let feed = uniqueImageFeed().models

        try await feedLoaderToPerformSave.save(feed)
        try await feedLoaderToPerformValidation.validateCache()

        #expect(try await feedLoaderToPerformSave.load() == [])
    }

    // MARK: - LocalFeedImageDataLoader Tests

    @Test(arguments: Store.allCases) func `Load image data delivers saved data on a separate instance`(store: Store) async throws {
        let imageLoaderToPerformSave = try makeImageLoader(store)
        let imageLoaderToPerformLoad = try makeImageLoader(store)
        let feedLoader = try makeFeedLoader(store)
        let image = uniqueImage()
        let dataToSave = anyData()

        try await feedLoader.save([image])
        try await imageLoaderToPerformSave.save(dataToSave, for: image.url)

        #expect(try await imageLoaderToPerformLoad.loadImageData(from: image.url) == dataToSave)
    }

    @Test(arguments: Store.allCases) func `Save image data overrides saved image data on a separate instance`(store: Store) async throws {
        let imageLoaderToPerformFirstSave = try makeImageLoader(store)
        let imageLoaderToPerformLastSave = try makeImageLoader(store)
        let imageLoaderToPerformLoad = try makeImageLoader(store)
        let feedLoader = try makeFeedLoader(store)
        let image = uniqueImage()
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)

        try await feedLoader.save([image])
        try await imageLoaderToPerformFirstSave.save(firstImageData, for: image.url)
        try await imageLoaderToPerformLastSave.save(lastImageData, for: image.url)

        #expect(try await imageLoaderToPerformLoad.loadImageData(from: image.url) == lastImageData)
    }

    @Test(arguments: Store.allCases)
    func `Load image data delivers saved data after saving the feed again`(store: Store) async throws {
        let storeToPerformSaves = try store.make(at: testSpecificStoreURL())
        let feedLoaderToPerformSaves = LocalFeedLoader(store: storeToPerformSaves, currentDate: Date.init)
        let imageLoaderToPerformSave = LocalFeedImageDataLoader(store: storeToPerformSaves)
        let imageLoaderToPerformLoad = try makeImageLoader(store)
        let image = uniqueImage()
        let dataToSave = anyData()
        trackForMemoryLeaks(storeToPerformSaves)

        try await feedLoaderToPerformSaves.save([image])
        try await imageLoaderToPerformSave.save(dataToSave, for: image.url)
        try await feedLoaderToPerformSaves.save([image, uniqueImage()])

        #expect(try await imageLoaderToPerformLoad.loadImageData(from: image.url) == dataToSave)
    }

    // MARK: - Helpers

    private func makeFeedLoader(_ store: Store, currentDate: Date = Date()) throws -> LocalFeedLoader {
        let store = try store.make(at: testSpecificStoreURL())
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)

        return sut
    }

    private func makeImageLoader(_ store: Store) throws -> LocalFeedImageDataLoader {
        let store = try store.make(at: testSpecificStoreURL())
        let sut = LocalFeedImageDataLoader(store: store)

        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)

        return sut
    }

    private func testSpecificStoreURL() -> URL {
        storeDirectory.appendingPathComponent("feed.store")
    }

    /// The store implementations the app can cache with. Each runs the whole suite.
    enum Store: CaseIterable, CustomTestStringConvertible {
        case coreData
        case swiftData

        func make(at storeURL: URL) throws -> any FeedStore & FeedImageDataStore & AnyObject {
            switch self {
                case .coreData: try CoreDataFeedStore(storeURL: storeURL)
                case .swiftData: try SwiftDataFeedStore(storeURL: storeURL)
            }
        }

        var testDescription: String {
            switch self {
                case .coreData: "Core Data"
                case .swiftData: "SwiftData"
            }
        }
    }
}
