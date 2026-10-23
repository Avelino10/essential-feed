//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 04/06/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

struct FeedItemsMapperTests {
    @Test(arguments: [199, 201, 300, 400, 500])
    func `Map throws error on non-200 HTTP response`(statusCode: Int) {
        let json = makeItemsJSON([])

        #expect(throws: FeedItemsMapper.Error.invalidData) {
            try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: statusCode))
        }
    }

    @Test func `Map throws error on 200 HTTP response with invalid JSON`() {
        let invalidJSON = Data("invalidJSON".utf8)

        #expect(throws: FeedItemsMapper.Error.invalidData) {
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        }
    }

    @Test func `Map delivers no items on 200 HTTP response with empty JSON list`() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try FeedItemsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: 200))

        #expect(result == [])
    }

    @Test func `Map delivers items on 200 HTTP response with JSON items`() throws {
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)

        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://another-url.com")!)

        let json = makeItemsJSON([item1.json, item2.json])

        let result = try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: 200))

        #expect(result == [item1.model, item2.model])
    }

    // MARK: - Helpers

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].compactMapValues { $0 }

        return (item, json)
    }
}
