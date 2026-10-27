//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import EssentialFeed
import EssentialFeediOS
import EssentialFeedTestHelpers
import Foundation

extension FeedUIIntegrationTests {
    /// Every read and completion first lets the UI's loading tasks run, then
    /// completions let the UI handle the result before the test carries on.
    @MainActor
    final class LoaderSpy {
        // MARK: - FeedLoader

        private let feedRequests = PendingRequests<Paginated<FeedImage>>()

        var loadFeedCallCount: Int {
            get async {
                await settle()
                return feedRequests.count
            }
        }

        func loadFeed() async throws -> Paginated<FeedImage> {
            try await feedRequests.load()
        }

        func completeFeedLoadingWithError(at index: Int = 0) async {
            await settle()
            feedRequests.fail(with: anyNSError(), at: index)
            await settle()
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) async {
            await settle()
            feedRequests.complete(with: makePage(feed), at: index)
            await settle()
        }

        // MARK: - LoadMoreFeedLoader

        private let loadMoreRequests = PendingRequests<Paginated<FeedImage>>()

        var loadMoreCallCount: Int {
            get async {
                await settle()
                return loadMoreRequests.count
            }
        }

        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int = 0) async {
            await settle()
            loadMoreRequests.complete(with: makePage(feed, lastPage: lastPage), at: index)
            await settle()
        }

        func completeLoadMoreWithError(at index: Int = 0) async {
            await settle()
            loadMoreRequests.fail(with: anyNSError(), at: index)
            await settle()
        }

        private func makePage(_ feed: [FeedImage], lastPage: Bool = false) -> Paginated<FeedImage> {
            Paginated(items: feed, loadMore: lastPage ? nil : { @Sendable [weak self] in
                guard let self else { throw CancellationError() }
                return try await loadMoreRequests.load()
            })
        }

        // MARK: - FeedImageDataLoader

        private let imageRequests = PendingRequests<Data>()
        private var requestedImageURLs = [URL]()

        var loadedImageURLs: [URL] {
            get async {
                await settle()
                return requestedImageURLs
            }
        }

        var cancelledImageURLs: [URL] {
            get async {
                await settle()
                return imageRequests.cancelledIndices.map { requestedImageURLs[$0] }
            }
        }

        func loadImageData(from url: URL) async throws -> Data {
            requestedImageURLs.append(url)
            return try await imageRequests.load()
        }

        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) async {
            await settle()
            imageRequests.complete(with: imageData, at: index)
            await settle()
        }

        func completeImageLoadingWithError(at index: Int = 0) async {
            await settle()
            imageRequests.fail(with: anyNSError(), at: index)
            await settle()
        }
    }
}
