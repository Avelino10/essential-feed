//
//  FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import Testing

// Specs for a `FeedStore` whose deletion can fail. Call them with a store set up to fail.

func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore) {
    #expect(throws: (any Error).self, "Expected cache deletion to fail") {
        try sut.deleteCachedFeed()
    }
}

func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore) throws {
    try? sut.deleteCachedFeed()

    try expect(sut, toRetrieve: nil)
}
