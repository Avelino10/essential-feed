//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 08/01/2022.
//

import Combine
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import EssentialFeedTestHelpers
import Foundation
import Testing

@MainActor
@Suite(.trackingMemoryLeaks)
struct CommentsUIIntegrationTests {
    @Test func `Comments view has title`() {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.title == commentsTitle)
    }

    @Test func `Load comments actions request comments from loader`() {
        let (sut, loader) = makeSUT()
        #expect(loader.loadCommentsCallCount == 0, "Expected no loading requests before view is loaded")

        sut.simulateAppearance()
        #expect(loader.loadCommentsCallCount == 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        #expect(loader.loadCommentsCallCount == 1, "Expected no request until previous completes")

        loader.completeCommentsLoading(at: 0)

        sut.simulateUserInitiatedReload()
        #expect(loader.loadCommentsCallCount == 2, "Expected another loading request once user initiated a load")

        loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        #expect(loader.loadCommentsCallCount == 3, "Expected a third loading request once user initiated another load")
    }

    @Test func `Loading comments indicator is visible while loading comments`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeCommentsLoading(at: 0)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")

        loader.completeCommentsLoadingWithError(at: 1)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    @Test func `Load comments completion renders successfully loaded comments`() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with: [comment0], at: 0)
        expect(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        expect(sut, isRendering: [comment0, comment1])
    }

    @Test func `Load comments completion renders successfully loaded empty comments after non-empty comments`() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [ImageComment]())

        loader.completeCommentsLoading(with: [comment], at: 0)
        expect(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        expect(sut, isRendering: [ImageComment]())
    }

    @Test func `Load comments completion does not alter current rendering state on error`() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        expect(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        expect(sut, isRendering: [comment])
    }

    @Test func `Load comments completion dispatches from background to main thread`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                loader.completeCommentsLoading(at: 0)
                continuation.resume()
            }
        }
    }

    @Test func `Load comments completion renders error message on error until next reload`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.errorMessage == nil)

        loader.completeCommentsLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateUserInitiatedReload()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Tap on error view hides error message`() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.errorMessage == nil)

        loader.completeCommentsLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateErrorViewTap()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Deinit cancels running request`() {
        var cancelCallCount = 0

        var sut: ListViewController?

        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: {
                PassthroughSubject<[ImageComment], Error>()
                    .handleEvents(receiveCancel: {
                        cancelCallCount += 1
                    }).eraseToAnyPublisher()
            })

            sut?.simulateAppearance()
        }

        #expect(cancelCallCount == 0)

        sut = nil
        #expect(cancelCallCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)

        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }

    private func expect(_ sut: ListViewController, isRendering comments: [ImageComment], fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        #expect(sut.numberOfRenderedComments() == comments.count, "comments count", sourceLocation: sourceLocation)

        let viewModel = ImageCommentsPresenter.map(comments)

        for (index, comment) in viewModel.comments.enumerated() {
            #expect(sut.commentMessage(at: index) == comment.message, "message at \(index)", sourceLocation: sourceLocation)
            #expect(sut.commentDate(at: index) == comment.date, "date at \(index)", sourceLocation: sourceLocation)
            #expect(sut.commentUsername(at: index) == comment.username, "username at \(index)", sourceLocation: sourceLocation)
        }
    }

    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Error>]()

        var loadCommentsCallCount: Int {
            requests.count
        }

        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            requests[index].send(comments)
            requests[index].send(completion: .finished)
        }

        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            requests[index].send(completion: .failure(error))
        }
    }
}
