//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 12/06/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

@Suite(.serialized, .trackingMemoryLeaks, .timeLimit(.minutes(1)))
struct URLSessionHTTPClientTests {
    init() {
        URLProtocolStub.removeStub()
    }

    @Test func `Get from URL performs GET request with URL`() async {
        let url = anyURL()

        await confirmation("Request observed") { requestObserved in
            URLProtocolStub.observeRequests { request in
                #expect(request.url == url)
                #expect(request.httpMethod == "GET")
                requestObserved()
            }

            _ = await resultFor(url: url)
        }
    }

    @Test func `Cancelling the get from URL task cancels the URL request`() async throws {
        let result = await resultFor(taskHandler: { $0.cancel() })

        let error = #expect(throws: URLError.self) { try result.get() }
        #expect(error?.code == .cancelled)
    }

    @Test func `Get from URL fails on request error`() async {
        let requestError = anyNSError()

        let result = await resultFor((data: nil, response: nil, error: requestError))

        let error = #expect(throws: NSError.self) { try result.get() }
        #expect(error?.domain == requestError.domain)
        #expect(error?.code == requestError.code)
    }

    @Test(arguments: [
        (nil, nil, nil),
        (nil, nonHTTPURLResponse(), nil),
        (anyData(), nil, nil),
        (anyData(), nil, anyNSError()),
        (nil, nonHTTPURLResponse(), anyNSError()),
        (nil, anyHTTPURLResponse(), anyNSError()),
        (anyData(), nonHTTPURLResponse(), anyNSError()),
        (anyData(), anyHTTPURLResponse(), anyNSError()),
        (anyData(), nonHTTPURLResponse(), nil),
    ] as [(Data?, URLResponse?, Error?)])
    func `Get from URL fails on invalid representation`(data: Data?, response: URLResponse?, error: Error?) async {
        let result = await resultFor((data: data, response: response, error: error))

        #expect(throws: (any Error).self) { try result.get() }
    }

    @Test func `Get from URL succeeds on HTTP URL response with data`() async throws {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let received = try await resultFor((data: data, response: response, error: nil)).get()

        #expect(received.0 == data)
        #expect(received.1.url == response.url)
        #expect(received.1.statusCode == response.statusCode)
    }

    @Test func `Get from URL succeeds with empty data on HTTP URL response with nil data`() async throws {
        let response = anyHTTPURLResponse()

        let received = try await resultFor((data: nil, response: response, error: nil)).get()

        let emptyData = Data()
        #expect(received.0 == emptyData)
        #expect(received.1.url == response.url)
        #expect(received.1.statusCode == response.statusCode)
    }

    // MARK: - Helpers

    private func makeSUT() -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut)
        return sut
    }

    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, url: URL = anyURL(), taskHandler: (HTTPClientTask) -> Void = { _ in }) async -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }

        let sut = makeSUT()

        return await withCheckedContinuation { continuation in
            taskHandler(sut.get(from: url) { result in
                continuation.resume(returning: result)
            })
        }
    }
}

private func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

private func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}
