//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 15/01/2022.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

struct FeedEndpointTests {
    @Test func `Feed endpoint URL`() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get().url(baseURL: baseURL)

        #expect(received.scheme == "http")
        #expect(received.host == "base-url.com")
        #expect(received.path == "/v1/feed")
        #expect(received.query == "limit=10")
    }

    @Test func `Feed endpoint URL after given image`() throws {
        let image = uniqueImage()
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get(after: image).url(baseURL: baseURL)

        #expect(received.scheme == "http")
        #expect(received.host == "base-url.com")
        #expect(received.path == "/v1/feed")
        let query = try #require(received.query)
        #expect(query.contains("limit=10"))
        #expect(query.contains("after_id=\(image.id)"))
    }
}
