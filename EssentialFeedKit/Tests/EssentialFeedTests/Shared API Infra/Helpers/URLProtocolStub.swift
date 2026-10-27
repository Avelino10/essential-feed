//
//  URLProtocolStub.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }

    // Guarded by `queue`.
    nonisolated(unsafe) private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }

    /// Completes observed requests with an empty 200 response: `URLSession` always
    /// finishes a request with either a response or an error.
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        let response = HTTPURLResponse(url: URL(string: "http://any-url.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        stub = Stub(data: nil, response: response, error: nil, requestObserver: observer)
    }

    static func removeStub() {
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        stub.requestObserver?(request)

        // The response has to come before the data: `URLSession`'s async API
        // pairs received bytes with the response that precedes them.
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
