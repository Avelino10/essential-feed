//
//  FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

// Specs for a `FeedStore` whose insertion can fail. Call them with a store set up to fail.

func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore) async {
    await #expect(throws: (any Error).self, "Expected cache insertion to fail with an error") {
        try await sut.insert(uniqueImageFeed().local, timestamp: Date())
    }
}

func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore) async throws {
    try? await sut.insert(uniqueImageFeed().local, timestamp: Date())

    try await expect(sut, toRetrieve: nil)
}
