//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Avelino Rodrigues on 22/06/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.trackingMemoryLeaks, .timeLimit(.minutes(1)))
struct EssentialFeedAPIEndToEndTests {
    @Test func `End-to-end test server GET feed result matches fixed test account data`() async throws {
        let (data, response) = try await get(from: feedTestServerURL)

        let imageFeed = try FeedItemsMapper.map(data, from: response)

        #expect(imageFeed == (0..<8).map(expectedImage(at:)))
    }

    @Test func `End-to-end test server GET feed image data result matches fixed test account data`() async throws {
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let (data, response) = try await get(from: url)

        let imageData = try FeedImageDataMapper.map(data, from: response)

        #expect(!imageData.isEmpty, "Expected non-empty image data")
    }

    // MARK: - Helpers

    private func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let client = ephemeralClient()

        return try await withCheckedThrowingContinuation { continuation in
            client.get(from: url) { result in
                continuation.resume(with: result)
            }
        }
    }

    private var feedTestServerURL: URL {
        URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }

    private func ephemeralClient() -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client)
        return client
    }

    private func expectedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index))
    }

    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01",
        ][index])!
    }

    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8",
        ][index]
    }

    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8",
        ][index]
    }

    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index + 1).com")!
    }
}
