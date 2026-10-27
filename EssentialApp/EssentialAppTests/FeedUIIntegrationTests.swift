//
//  FeedUIIntegrationTests.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 07/08/2021.
//

import EssentialApp
import EssentialFeed
import EssentialFeediOS
import EssentialFeedTestHelpers
import Foundation
import Testing
import UIKit

@MainActor
@Suite(.trackingMemoryLeaks)
struct FeedUIIntegrationTests {
    @Test func `Feed view has title`() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.title == feedTitle)
    }

    @Test func `Image selection notifies handler`() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })

        sut.simulateAppearance()

        loader.completeFeedLoading(with: [image0, image1], at: 0)

        sut.simulateTapOnFeedImage(at: 0)
        #expect(selectedImages == [image0])

        sut.simulateTapOnFeedImage(at: 1)
        #expect(selectedImages == [image0, image1])
    }

    @Test func `Load feed actions request feed from loader`() {
        let (sut, loader) = makeSUT()

        #expect(loader.loadFeedCallCount == 0, "Expected no loading requests before view is loaded")

        sut.simulateAppearance()
        #expect(loader.loadFeedCallCount == 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        #expect(loader.loadFeedCallCount == 1, "Expected no request until previous completes")

        loader.completeFeedLoading(at: 0)

        sut.simulateUserInitiatedReload()
        #expect(loader.loadFeedCallCount == 2, "Expected another loading request once user initiated a load")

        loader.completeFeedLoading(at: 1)
        sut.simulateUserInitiatedReload()
        #expect(loader.loadFeedCallCount == 3, "Expected a third loading request once user initiated another load")
    }

    @Test func `Load more actions request more from loader`() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading()

        #expect(loader.loadMoreCallCount == 0, "Expected no requests before until load more action")

        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 1, "Expected load more request")

        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 1, "Expected no request while loading more")

        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 2, "Expected request after load more completed with more pages")

        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 3, "Expected request after load more failure")

        loader.completeLoadMore(lastPage: true, at: 2)
        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 3, "Expected no request after loading all pages")
    }

    @Test func `Loading feed indicator is visible while loading feed`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")

        loader.completeFeedLoadingWithError(at: 1)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    @Test func `Load more indicator is visible while loading more`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(!sut.isShowingLoadMoreFeedIndicator, "Expected no indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        #expect(!sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateLoadMoreFeedAction()
        #expect(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on load more action")

        loader.completeLoadMore(at: 0)
        #expect(!sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes successfully")

        sut.simulateLoadMoreFeedAction()
        #expect(sut.isShowingLoadMoreFeedIndicator, "Expected loading indicator on second load more action")

        loader.completeLoadMoreWithError(at: 1)
        #expect(!sut.isShowingLoadMoreFeedIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    @Test func `Load feed completion renders successfully loaded feed`() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0, image1], at: 0)
        expect(sut, isRendering: [image0, image1])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1, image2, image3], at: 0)
        expect(sut, isRendering: [image0, image1, image2, image3])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1], at: 1)
        expect(sut, isRendering: [image0, image1])
    }

    @Test func `Load feed completion renders successfully loaded empty feed after non-empty feed`() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [])

        loader.completeFeedLoading(with: [image0], at: 0)
        expect(sut, isRendering: [image0])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        expect(sut, isRendering: [image0, image1])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        expect(sut, isRendering: [])
    }

    @Test func `Load feed completion does not alter current rendering state on error`() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        expect(sut, isRendering: [image0])

        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        expect(sut, isRendering: [image0])

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMoreWithError(at: 0)
        expect(sut, isRendering: [image0])
    }

    @Test func `Load feed completion dispatches from background to main thread`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                loader.completeFeedLoading(at: 0)
                continuation.resume()
            }
        }
    }

    @Test func `Load more completion dispatches from background to main thread`() async {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(at: 0)
        sut.simulateLoadMoreFeedAction()

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                loader.completeLoadMore()
                continuation.resume()
            }
        }
    }

    @Test func `Load feed completion renders error message on error until next reload`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.errorMessage == nil)

        loader.completeFeedLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateUserInitiatedReload()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Tap on error view hides error message`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.errorMessage == nil)

        loader.completeFeedLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateErrorViewTap()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Load more completion renders error message on error`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()

        sut.simulateLoadMoreFeedAction()
        #expect(sut.loadMoreFeedErrorMessage == nil)

        loader.completeLoadMoreWithError()
        #expect(sut.loadMoreFeedErrorMessage == loadError)

        sut.simulateLoadMoreFeedAction()
        #expect(sut.loadMoreFeedErrorMessage == nil)
    }

    @Test func `Tap on load more error view loads more`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading()

        sut.simulateLoadMoreFeedAction()
        #expect(loader.loadMoreCallCount == 1)

        sut.simulateTapOnLoadMoreFeedError()
        #expect(loader.loadMoreCallCount == 1)

        loader.completeLoadMoreWithError()
        sut.simulateTapOnLoadMoreFeedError()
        #expect(loader.loadMoreCallCount == 2)
    }

    // MARK: - Image View Tests

    @Test func `Feed image view loads image URL when visible`() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        #expect(loader.loadedImageURLs == [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        #expect(loader.loadedImageURLs == [image0.url], "Expected first image URL requests once first view becomes visible")

        sut.simulateFeedImageViewVisible(at: 1)
        #expect(loader.loadedImageURLs == [image0.url, image1.url], "Expected second image URL requests once second view also becomes visible")
    }

    @Test func `Feed image view loading indicator is visible while loading image`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        #expect(view0?.isShowingImageLoadingIndicator == true, "Expected loading indicator for first view while loading first image")
        #expect(view1?.isShowingImageLoadingIndicator == true, "Expected loading indicator for second view while loading second image")

        loader.completeImageLoading(at: 0)
        #expect(view0?.isShowingImageLoadingIndicator == false, "Expected no loading indicator for first view once first image loading completes successfully")
        #expect(view1?.isShowingImageLoadingIndicator == true, "Expected no loading indicator state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        #expect(view0?.isShowingImageLoadingIndicator == false, "Expected no loading indicator state change for first view once second image loading completes with error")
        #expect(view1?.isShowingImageLoadingIndicator == false, "Expected no loading indicator for second view once second image loading completes with error")
    }

    @Test func `Feed image view renders image loaded from URL`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        #expect(view0?.renderedImage == .none, "Expected no image for first view while loading first image")
        #expect(view1?.renderedImage == .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        #expect(view0?.renderedImage == imageData0.imagePixels, "Expected image for first view once first image loading completes successfully")
        #expect(view1?.renderedImage == .none, "Expected no image state change for second view once first image loading completes successfully")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        #expect(view0?.renderedImage == imageData0.imagePixels, "Expected no image state change for first view once second image loading completes successfully")
        #expect(view1?.renderedImage == imageData1.imagePixels, "Expected image for second view once second image loading completes successfully")
    }

    @Test func `Feed image view retry button is visible on image URL load error`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        #expect(view0?.isShowingRetryAction == false, "Expected no retry action for first view while loading first image")
        #expect(view1?.isShowingRetryAction == false, "Expected no retry action for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        #expect(view0?.isShowingRetryAction == false, "Expected no retry action for first view once first image loading completes successfully")
        #expect(view1?.isShowingRetryAction == false, "Expected no retry action state change for second view once first image loading completes successfully")

        loader.completeImageLoadingWithError(at: 1)
        #expect(view0?.isShowingRetryAction == false, "Expected no retry action state change for first view once second image loading completes with error")
        #expect(view1?.isShowingRetryAction == true, "Expected retry action for second view once second image loading completes with error")
    }

    @Test func `Feed image view retry button is visible on invalid image data`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageViewVisible(at: 0)
        #expect(view?.isShowingRetryAction == false, "Expected no retry action while loading first image")

        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        #expect(view?.isShowingRetryAction == true, "Expected retry action once image loading completes with invalid image data")
    }

    @Test func `Feed image view retry action retries image load`() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        #expect(loader.loadedImageURLs == [image0.url, image1.url], "Expected two image URL request for the two visible views")

        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        #expect(loader.loadedImageURLs == [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateRetryAction()
        #expect(loader.loadedImageURLs == [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")

        view1?.simulateRetryAction()
        #expect(loader.loadedImageURLs == [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }

    @Test func `Feed image view preloads image URL when near visible`() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        #expect(loader.loadedImageURLs == [], "Expected no image URL request until image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 0)
        #expect(loader.loadedImageURLs == [image0.url], "Expected first image URL request once first image is near visible")

        sut.simulateFeedImageViewNearVisible(at: 1)
        #expect(loader.loadedImageURLs == [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }

    @Test func `Feed image view cancels image URL when not near visible anymore`() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        #expect(loader.cancelledImageURLs == [], "Expected no cancelled image URL requests until image is not near visible")

        sut.simulateFeedImageViewNotNearVisible(at: 0)
        #expect(loader.cancelledImageURLs == [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")

        sut.simulateFeedImageViewNotNearVisible(at: 1)
        #expect(loader.cancelledImageURLs == [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }

    @Test func `Feed image view cancels image loading when not visible anymore`() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        #expect(loader.cancelledImageURLs == [], "Expected no cancelled image URL requests until image is not visible")

        sut.simulateFeedImageViewNotVisible(at: 0)
        #expect(loader.cancelledImageURLs == [image0.url], "Expected on cancelled image URL request once first image is not visible anymore")

        sut.simulateFeedImageViewNotVisible(at: 1)
        #expect(loader.cancelledImageURLs == [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }

    @Test func `Feed image view does not render loaded image when not visible anymore`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])

        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData())

        #expect(view?.renderedImage == nil, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }

    @Test func `Load image data completion dispatches from background to main thread`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        _ = sut.simulateFeedImageViewVisible(at: 0)

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                loader.completeImageLoading(with: self.anyImageData(), at: 0)
                continuation.resume()
            }
        }
    }

    @Test func `Feed image view does not load image again until previous request completes`() {
        let image = makeImage(url: URL(string: "http://url-0.com")!)
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image])

        sut.simulateFeedImageViewNearVisible(at: 0)
        #expect(loader.loadedImageURLs == [image.url], "Expected first request when near visible")

        sut.simulateFeedImageViewVisible(at: 0)
        #expect(loader.loadedImageURLs == [image.url], "Expected no request until previous completes")

        loader.completeImageLoading(at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        #expect(loader.loadedImageURLs == [image.url, image.url], "Expected second request when visible after previous complete")

        sut.simulateFeedImageViewNotVisible(at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        #expect(loader.loadedImageURLs == [image.url, image.url, image.url], "Expected third request when visible after canceling previous complete")

        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image, makeImage()])
        sut.simulateFeedImageViewVisible(at: 0)
        #expect(loader.loadedImageURLs == [image.url, image.url, image.url], "Expected no request until previous completes")
    }

    // MARK: - Helpers

    private func makeSUT(selection: @escaping (FeedImage) -> Void = { _ in }) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(feedLoader: loader.loadPublisher, imageLoader: loader.loadImageDataPublisher, selection: selection)

        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
}
