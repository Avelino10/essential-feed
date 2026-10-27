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
    @Test func `Retrieve delivers empty on empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    @Test func `Retrieve has no side effects on empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    @Test func `Retrieve delivers found values on non-empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    @Test func `Retrieve has no side effects on non-empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    @Test func `Insert delivers no error on empty cache`() async throws {
        let sut = try makeSUT()

        await assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }

    @Test func `Insert delivers no error on non-empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    @Test func `Insert overrides previously inserted cache values`() async throws {
        let sut = try makeSUT()

        try await assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    @Test func `Delete delivers no error on empty cache`() async throws {
        let sut = try makeSUT()

        await assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    @Test func `Delete has no side effects on empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    @Test func `Delete delivers no error on non-empty cache`() async throws {
        let sut = try makeSUT()

        try await assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }

    @Test func `Delete empties previously inserted cache`() async throws {
        let sut = try makeSUT()

        try await assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }

    // MARK: - Helpers

    private func makeSUT() throws -> FeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut)
        return sut
    }
}
