//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 03/08/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks)
struct CoreDataFeedStoreTests {
    @Test func `Retrieve delivers empty on empty cache`() throws {
        let sut = try makeSUT()

        try assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    @Test func `Retrieve has no side effects on empty cache`() throws {
        let sut = try makeSUT()

        try assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    @Test func `Retrieve delivers found values on non-empty cache`() throws {
        let sut = try makeSUT()

        try assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    @Test func `Retrieve has no side effects on non-empty cache`() throws {
        let sut = try makeSUT()

        try assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    @Test func `Insert delivers no error on empty cache`() throws {
        let sut = try makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    @Test func `Insert delivers no error on non-empty cache`() throws {
        let sut = try makeSUT()

        try assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    @Test func `Insert overrides previously inserted cache values`() throws {
        let sut = try makeSUT()

        try assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    @Test func `Delete delivers no error on empty cache`() throws {
        let sut = try makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    @Test func `Delete has no side effects on empty cache`() throws {
        let sut = try makeSUT()

        try assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    @Test func `Delete delivers no error on non-empty cache`() throws {
        let sut = try makeSUT()

        try assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    @Test func `Delete empties previously inserted cache`() throws {
        let sut = try makeSUT()

        try assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    // MARK: - Helpers

    private func makeSUT() throws -> FeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
}
