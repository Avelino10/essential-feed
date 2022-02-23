//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .success(.some(CachedFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(.some(CachedFeed(feed: feed, timestamp: timestamp))), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)

        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        insert((uniqueImageFeed().local, Date()), to: sut)
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)

        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(.some(CachedFeed(feed: latestFeed, timestamp: latestTimestamp))))
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none))
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueImageFeed().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none))
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        var deletionError: Error?

        do {
            try sut.deleteCachedFeed()
        } catch {
            deletionError = error
        }

        return deletionError
    }

    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        var insertionError: Error?

        do {
            try sut.insert(cache.feed, timestamp: cache.timestamp)
        } catch {
            insertionError = error
        }

        return insertionError
    }

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(_ sut: FeedStore, toRetrieve expectedResult: Result<CachedFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
        let retrievedResult = Result { try? sut.retrieve() }
        switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
        }
    }
}
