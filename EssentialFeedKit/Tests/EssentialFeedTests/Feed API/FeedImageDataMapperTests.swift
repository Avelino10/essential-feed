//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

struct FeedImageDataMapperTests {
    @Test(arguments: [199, 201, 300, 400, 500])
    func `Map throws error on non-200 HTTP response`(statusCode: Int) {
        #expect(throws: FeedImageDataMapper.Error.invalidData) {
            try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: statusCode))
        }
    }

    @Test func `Map delivers invalid data error on 200 HTTP response with empty data`() {
        let emptyData = Data()

        #expect(throws: FeedImageDataMapper.Error.invalidData) {
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        }
    }

    @Test func `Map delivers non-empty received data on 200 HTTP response`() throws {
        let nonEmptyData = anyData()

        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))

        #expect(result == nonEmptyData)
    }
}
