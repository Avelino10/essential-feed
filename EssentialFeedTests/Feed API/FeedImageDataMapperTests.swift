//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import EssentialFeed
import XCTest

class FeedImageDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }

    func test_map_deliversNonEmptyReceivedDataOn200HTTPResponse() throws {
        let nonEmptyData = anyData()

        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, nonEmptyData)
    }
}
