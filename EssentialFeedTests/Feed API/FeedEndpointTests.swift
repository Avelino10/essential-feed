//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 15/01/2022.
//

import EssentialFeed
import XCTest

class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/feed")!

        XCTAssertEqual(received, expected)
    }
}
