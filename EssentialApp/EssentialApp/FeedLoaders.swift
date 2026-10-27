//
//  FeedLoaders.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 27/10/2026.
//

import EssentialFeed
import Foundation

/// How the app loads its content. The feed and its images come from the server first,
/// are cached as they arrive, and fall back to the cache when the server can't be reached.
/// Comments always come from the server.
///
/// The loads are `@concurrent`, so they run off the caller's actor (usually the main actor).
struct FeedLoaders: Sendable {
    let httpClient: HTTPClient
    let localFeedLoader: LocalFeedLoader
    let localImageLoader: LocalFeedImageDataLoader
    let baseURL: URL

    @concurrent func loadFirstPage() async throws -> Paginated<FeedImage> {
        let items: [FeedImage]

        do {
            items = try await loadRemoteFeed()
            await cacheIgnoringErrors(items)
        } catch {
            items = try await localFeedLoader.load()
        }

        return makePage(items: items, last: items.last)
    }

    @concurrent func loadImageData(from url: URL) async throws -> Data {
        do {
            return try await localImageLoader.loadImageData(from: url)
        } catch {
            let (data, response) = try await httpClient.get(from: url)
            let imageData = try FeedImageDataMapper.map(data, from: response)
            try? await localImageLoader.save(imageData, for: url)
            return imageData
        }
    }

    @concurrent func loadComments(from url: URL) async throws -> [ImageComment] {
        let (data, response) = try await httpClient.get(from: url)
        return try ImageCommentsMapper.map(data, from: response)
    }

    @concurrent private func loadMore(after last: FeedImage) async throws -> Paginated<FeedImage> {
        async let cachedItems = localFeedLoader.load()
        async let newItems = loadRemoteFeed(after: last)
        let (cached, new) = try await (cachedItems, newItems)

        let page = makePage(items: cached + new, last: new.last)
        await cacheIgnoringErrors(page.items)
        return page
    }

    private func loadRemoteFeed(after last: FeedImage? = nil) async throws -> [FeedImage] {
        let url = FeedEndpoint.get(after: last).url(baseURL: baseURL)
        let (data, response) = try await httpClient.get(from: url)
        return try FeedItemsMapper.map(data, from: response)
    }

    private func cacheIgnoringErrors(_ items: [FeedImage]) async {
        try? await localFeedLoader.save(items)
    }

    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMore: last.map { last in
            { @Sendable in try await loadMore(after: last) }
        })
    }
}
