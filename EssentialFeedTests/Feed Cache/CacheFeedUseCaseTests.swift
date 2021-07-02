//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/07/2021.
//

import XCTest

class LocalFeedLoader {
    init(store: FeedStore) {
    }
}

class FeedStore {
    var deleteCahcedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCahcedFeedCallCount, 0)
    }
}
