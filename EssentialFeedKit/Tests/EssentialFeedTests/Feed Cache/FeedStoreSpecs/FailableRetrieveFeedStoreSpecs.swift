//
//  FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 31/07/2021.
//

import EssentialFeed
import Testing

// Specs for a `FeedStore` whose retrieval can fail. Call them with a store set up to fail.

func assertThatRetrieveDeliversErrorOnRetrievalError(on sut: FeedStore) async {
    await #expect(throws: (any Error).self) { try await sut.retrieve() }
}

func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore) async {
    await #expect(throws: (any Error).self) { try await sut.retrieve() }
    await #expect(throws: (any Error).self) { try await sut.retrieve() }
}
