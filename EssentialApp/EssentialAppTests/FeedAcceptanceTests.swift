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
    @Test func `On launch displays remote feed when customer has connectivity`() async throws {
        let feed = try await launch(httpClient: .online { response(for: $0) })

        #expect(feed.numberOfRenderedFeedImageViews() == 2)
        #expect(await renderedImageData(in: feed, at: 0) == makeImageData0().imagePixels)
        #expect(await renderedImageData(in: feed, at: 1) == makeImageData1().imagePixels)
        #expect(feed.canLoadMoreFeed)

        await loadMore(in: feed)

        #expect(feed.numberOfRenderedFeedImageViews() == 3)
        #expect(await renderedImageData(in: feed, at: 0) == makeImageData0().imagePixels)
        #expect(await renderedImageData(in: feed, at: 1) == makeImageData1().imagePixels)
        #expect(await renderedImageData(in: feed, at: 2) == makeImageData2().imagePixels)
        #expect(feed.canLoadMoreFeed)

        await loadMore(in: feed)

        #expect(feed.numberOfRenderedFeedImageViews() == 3)
        #expect(await renderedImageData(in: feed, at: 0) == makeImageData0().imagePixels)
        #expect(await renderedImageData(in: feed, at: 1) == makeImageData1().imagePixels)
        #expect(await renderedImageData(in: feed, at: 2) == makeImageData2().imagePixels)
        #expect(!feed.canLoadMoreFeed)
    }

    @Test(arguments: CacheStore.allCases)
    func `On launch displays cached remote feed when customer has no connectivity`(cacheStore: CacheStore) async throws {
        let storeDirectory = try makeStoreDirectory()

        let onlineFeed = try await launch(httpClient: .online { response(for: $0) }, store: cacheStore.make(in: storeDirectory))
        _ = await renderedImageData(in: onlineFeed, at: 0)
        _ = await renderedImageData(in: onlineFeed, at: 1)
        await loadMore(in: onlineFeed)
        _ = await renderedImageData(in: onlineFeed, at: 2)
        let offlineFeed = try await launch(httpClient: .offline, store: cacheStore.make(in: storeDirectory))

        #expect(offlineFeed.numberOfRenderedFeedImageViews() == 3)
        #expect(await renderedImageData(in: offlineFeed, at: 0) == makeImageData0().imagePixels)
        #expect(await renderedImageData(in: offlineFeed, at: 1) == makeImageData1().imagePixels)
        #expect(await renderedImageData(in: offlineFeed, at: 2) == makeImageData2().imagePixels)
    }

    @Test(arguments: CacheStore.allCases)
    func `On launch displays empty feed when customer has no connectivity and no cache`(cacheStore: CacheStore) async throws {
        let storeDirectory = try makeStoreDirectory()

        let feed = try await launch(httpClient: .offline, store: cacheStore.make(in: storeDirectory))

        #expect(feed.numberOfRenderedFeedImageViews() == 0)
    }

    @Test func `On entering background deletes expired feed cache`() async throws {
        let store = InMemoryFeedStore.withExpiredFeedCache

        try await enterBackground(with: store)

        #expect(store.feedCache == nil, "Expected to delete expired cache")
    }

    @Test func `On entering background keeps non-expired feed cache`() async throws {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        try await enterBackground(with: store)

        #expect(store.feedCache != nil, "Expected to keep non-expired cache")
    }

    @Test func `On feed image selection displays comments`() async throws {
        let comments = try await showCommentsForFirstImage()

        #expect(comments.numberOfRenderedComments() == 1)
        #expect(comments.commentMessage(at: 0) == makeCommentMessage())
    }

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline, store: FeedStore & FeedImageDataStore = InMemoryFeedStore.empty) async throws -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        sut.configureWindow()

        let nav = try #require(sut.window?.rootViewController as? UINavigationController)
        let feed = try #require(nav.topViewController as? ListViewController)

        feed.simulateAppearance()
        await waitUntil { !feed.isShowingLoadingIndicator }
        return feed
    }

    private func loadMore(in feed: ListViewController) async {
        feed.simulateLoadMoreFeedAction()
        await waitUntil { !feed.isShowingLoadMoreFeedIndicator }
    }

    /// The table lays out and reuses cells on its own, so while an image load is in flight the
    /// row's cell controller can switch to a different cell. If the cell we hold doesn't get
    /// the image shortly, ask for the row again, which starts a new load if the last one ended.
    private func renderedImageData(in feed: ListViewController, at index: Int) async -> [UInt8]? {
        let deadline = ContinuousClock.now + .seconds(2)

        while ContinuousClock.now < deadline {
            let view = feed.simulateFeedImageViewVisible(at: index)
            await waitUntil(timeout: .milliseconds(100)) { view?.renderedImage != nil }

            if let image = view?.renderedImage {
                return image
            }
        }

        return nil
    }

    /// Loads complete asynchronously and reach the UI on a later main-queue turn,
    /// so the tests wait for each one to finish before checking the UI.
    private func waitUntil(timeout: Duration = .seconds(2), _ condition: () -> Bool) async {
        let deadline = ContinuousClock.now + timeout
        while !condition(), ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(1))
        }
    }

    /// The launched UI keeps its store open after the test ends, so the store files are never
    /// deleted mid-run. Each run clears the previous run's files instead.
    private static let storesDirectory: URL = {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(FeedAcceptanceTests.self)", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        return directory
    }()

    private func makeStoreDirectory() throws -> URL {
        let directory = Self.storesDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func enterBackground(with store: InMemoryFeedStore) async throws {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        let scene = try #require(UIApplication.shared.connectedScenes.first)
        sut.sceneWillResignActive(scene)
        await sut.cacheValidation?.value
    }

    private func showCommentsForFirstImage() async throws -> ListViewController {
        let feed = try await launch(httpClient: .online { response(for: $0) })

        feed.simulateTapOnFeedImage(at: 0)

        let nav = try #require(feed.navigationController)
        await waitUntil { nav.topViewController !== feed }
        let comments = try #require(nav.topViewController as? ListViewController)
        comments.simulateAppearance()
        await waitUntil { !comments.isShowingLoadingIndicator }
        return comments
    }

    private final class HTTPClientStub: HTTPClient {
        private let stub: @Sendable (URL) throws -> (Data, HTTPURLResponse)

        init(stub: @escaping @Sendable (URL) throws -> (Data, HTTPURLResponse)) {
            self.stub = stub
        }

        func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
            try stub(url)
        }

        static var offline: HTTPClientStub {
            HTTPClientStub(stub: { _ in throw NSError(domain: "offline", code: 0) })
        }

        static func online(_ stub: @escaping @Sendable (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
            HTTPClientStub(stub: stub)
        }
    }

    private nonisolated func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private nonisolated func makeData(for url: URL) -> Data {
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

    private nonisolated func makeImageData0() -> Data { UIImage.make(withColor: .red).pngData()! }
    private nonisolated func makeImageData1() -> Data { UIImage.make(withColor: .green).pngData()! }
    private nonisolated func makeImageData2() -> Data { UIImage.make(withColor: .blue).pngData()! }

    private nonisolated func makeFirstFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "2AB2AE66-A4B7-4A16-B374-51BBAC8DB086", "image": "http://feed.com/image-0"],
            ["id": "A28F5FE3-27A7-44E9-8DF5-53742D0E4A5A", "image": "http://feed.com/image-1"],
        ]])
    }

    private nonisolated func makeSecondFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "166FCDD7-C9F4-420A-B2D6-CE2EAFA3D82F", "image": "http://feed.com/image-2"],
        ]])
    }

    private nonisolated func makeLastEmptyFeedPageData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
    }

    private nonisolated func makeCommentsData() -> Data {
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

    private nonisolated func makeCommentMessage() -> String {
        "a message"
    }
}
