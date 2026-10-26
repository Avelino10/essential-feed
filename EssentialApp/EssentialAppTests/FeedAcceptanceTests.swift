//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 29/10/2021.
//

@testable import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Testing
import UIKit

@MainActor
struct FeedAcceptanceTests {
    @Test func `On launch displays remote feed when customer has connectivity`() throws {
        let feed = try launch(httpClient: .online(response), store: .empty)

        #expect(feed.numberOfRenderedFeedImageViews() == 2)
        #expect(feed.renderedFeedImageData(at: 0) == makeImageData0().imagePixels)
        #expect(feed.renderedFeedImageData(at: 1) == makeImageData1().imagePixels)
        #expect(feed.canLoadMoreFeed)

        feed.simulateLoadMoreFeedAction()

        #expect(feed.numberOfRenderedFeedImageViews() == 3)
        #expect(feed.renderedFeedImageData(at: 0) == makeImageData0().imagePixels)
        #expect(feed.renderedFeedImageData(at: 1) == makeImageData1().imagePixels)
        #expect(feed.renderedFeedImageData(at: 2) == makeImageData2().imagePixels)
        #expect(feed.canLoadMoreFeed)

        feed.simulateLoadMoreFeedAction()

        #expect(feed.numberOfRenderedFeedImageViews() == 3)
        #expect(feed.renderedFeedImageData(at: 0) == makeImageData0().imagePixels)
        #expect(feed.renderedFeedImageData(at: 1) == makeImageData1().imagePixels)
        #expect(feed.renderedFeedImageData(at: 2) == makeImageData2().imagePixels)
        #expect(!feed.canLoadMoreFeed)
    }

    @Test func `On launch displays cached remote feed when customer has no connectivity`() throws {
        let sharedStore = InMemoryFeedStore.empty

        let onlineFeed = try launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)
        let offlineFeed = try launch(httpClient: .offline, store: sharedStore)

        #expect(offlineFeed.numberOfRenderedFeedImageViews() == 3)
        #expect(offlineFeed.renderedFeedImageData(at: 0) == makeImageData0().imagePixels)
        #expect(offlineFeed.renderedFeedImageData(at: 1) == makeImageData1().imagePixels)
        #expect(offlineFeed.renderedFeedImageData(at: 2) == makeImageData2().imagePixels)
    }

    @Test func `On launch displays empty feed when customer has no connectivity and no cache`() throws {
        let feed = try launch(httpClient: .offline, store: .empty)

        #expect(feed.numberOfRenderedFeedImageViews() == 0)
    }

    @Test func `On entering background deletes expired feed cache`() throws {
        let store = InMemoryFeedStore.withExpiredFeedCache

        try enterBackground(with: store)

        #expect(store.feedCache == nil, "Expected to delete expired cache")
    }

    @Test func `On entering background keeps non-expired feed cache`() throws {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        try enterBackground(with: store)

        #expect(store.feedCache != nil, "Expected to keep non-expired cache")
    }

    @Test func `On feed image selection displays comments`() throws {
        let comments = try showCommentsForFirstImage()

        #expect(comments.numberOfRenderedComments() == 1)
        #expect(comments.commentMessage(at: 0) == makeCommentMessage())
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline, store: InMemoryFeedStore = .empty) throws -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store, scheduler: .immediateOnMainQueue)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()

        let nav = try #require(sut.window?.rootViewController as? UINavigationController)
        let feed = try #require(nav.topViewController as? ListViewController)
        feed.simulateAppearance()
        return feed
    }

    private func enterBackground(with store: InMemoryFeedStore) throws {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store, scheduler: .immediateOnMainQueue)
        let scene = try #require(UIApplication.shared.connectedScenes.first)
        sut.sceneWillResignActive(scene)
    }

    private func showCommentsForFirstImage() throws -> ListViewController {
        let feed = try launch(httpClient: .online(response), store: .empty)

        feed.simulateTapOnFeedImage(at: 0)
        RunLoop.current.run(until: Date())

        let nav = try #require(feed.navigationController)
        let comments = try #require(nav.topViewController as? ListViewController)
        comments.simulateAppearance()
        return comments
    }

    private class HTTPClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }

        private let stub: (URL) -> HTTPClient.Result

        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub { url in .success(stub(url)) }
        }
    }

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.path {
            case "/image-0": return makeImageData0()
            case "/image-1": return makeImageData1()
            case "/image-2": return makeImageData2()
            case "/essential-feed/v1/feed" where url.query?.contains("after_id") == false:
                return makeFirstFeedPageData()
            case "/essential-feed/v1/feed" where url.query?.contains("after_id=A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A") == true:
                return makeSecondFeedPageData()
            case "/essential-feed/v1/feed" where url.query?.contains("after_id=166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F") == true:
                return makeLastEmptyFeedPageData()
            case "/essential-feed/v1/image/2AB2AE66-A4B7-4A16-B374-51BBAC8DB086/comments":
                return makeCommentsData()
            default:
                return Data()
        }
    }

    private func makeImageData0() -> Data { UIImage.make(withColor: .red).pngData()! }
    private func makeImageData1() -> Data { UIImage.make(withColor: .green).pngData()! }
    private func makeImageData2() -> Data { UIImage.make(withColor: .blue).pngData()! }

    private func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-0"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-1"],
        ]])
    }

    private func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F", "image": "http://feed.com/image-2"],
        ]])
    }

    private func makeLastEmptyFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
    }

    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            [
                "id": UUID().uuidString,
                "message": makeCommentMessage(),
                "created_at": "2020-05-20T11:24:59+0000",
                "author": [
                    "username": "a username",
                ],
            ],
        ]])
    }

    private func makeCommentMessage() -> String {
        "a message"
    }
}
