//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 13/11/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

private let successStatusCodes = [200, 201, 250, 280, 299]

struct ImageCommentsMapperTests {
    @Test(arguments: [199, 150, 300, 400, 500])
    func `Map throws error on non-2xx HTTP response`(statusCode: Int) {
        let json = makeItemsJSON([])

        #expect(throws: ImageCommentsMapper.Error.invalidData) {
            try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: statusCode))
        }
    }

    @Test(arguments: successStatusCodes)
    func `Map throws error on 2xx HTTP response with invalid JSON`(statusCode: Int) {
        let invalidJSON = Data("invalidJSON".utf8)

        #expect(throws: ImageCommentsMapper.Error.invalidData) {
            try ImageCommentsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: statusCode))
        }
    }

    @Test(arguments: successStatusCodes)
    func `Map delivers no items on 2xx HTTP response with empty JSON list`(statusCode: Int) throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try ImageCommentsMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: statusCode))

        #expect(result == [])
    }

    @Test(arguments: successStatusCodes)
    func `Map delivers items on 2xx HTTP response with JSON items`(statusCode: Int) throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username"
        )

        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username"
        )

        let json = makeItemsJSON([item1.json, item2.json])

        let result = try ImageCommentsMapper.map(json, from: HTTPURLResponse(statusCode: statusCode))

        #expect(result == [item1.model, item2.model])
    }

    // MARK: - Helpers

    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8601String,
            "author": [
                "username": username,
            ],
        ]

        return (item, json)
    }
}
