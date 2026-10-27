//
//  FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import Testing

// Specs for a `FeedStore` whose deletion can fail. Call them with a store set up to fail.

func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore) async {
    await #expect(throws: (any Error).self, "Expected cache deletion to fail") {
        try await sut.deleteCachedFeed()
    }
}

func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore) async throws {
    try? await sut.deleteCachedFeed()

    try await expect(sut, toRetrieve: nil)
}
