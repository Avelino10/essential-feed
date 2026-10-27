//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 08/01/2022.
//

import EssentialApp
import EssentialFeed
import EssentialFeediOS
import EssentialFeedTestHelpers
import Foundation
import Testing

@MainActor
@Suite(.trackingMemoryLeaks)
struct CommentsUIIntegrationTests {
    @Test func `Comments view has title`() async {
        let (sut, _) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.title == commentsTitle)
    }

    @Test func `Load comments actions request comments from loader`() async {
        let (sut, loader) = makeSUT()
        #expect(await loader.loadCommentsCallCount == 0, "Expected no loading requests before view is loaded")

        sut.simulateAppearance()
        #expect(await loader.loadCommentsCallCount == 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedReload()
        #expect(await loader.loadCommentsCallCount == 1, "Expected no request until previous completes")

        await loader.completeCommentsLoading(at: 0)

        sut.simulateUserInitiatedReload()
        #expect(await loader.loadCommentsCallCount == 2, "Expected another loading request once user initiated a load")

        await loader.completeCommentsLoading(at: 1)
        sut.simulateUserInitiatedReload()
        #expect(await loader.loadCommentsCallCount == 3, "Expected a third loading request once user initiated another load")
    }

    @Test func `Loading comments indicator is visible while loading comments`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        await loader.completeCommentsLoading(at: 0)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")

        sut.simulateUserInitiatedReload()
        #expect(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiated a reload")

        await loader.completeCommentsLoadingWithError(at: 1)
        #expect(!sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    @Test func `Load comments completion renders successfully loaded comments`() async {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [ImageComment]())

        await loader.completeCommentsLoading(with: [comment0], at: 0)
        expect(sut, isRendering: [comment0])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        expect(sut, isRendering: [comment0, comment1])
    }

    @Test func `Load comments completion renders successfully loaded empty comments after non-empty comments`() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        expect(sut, isRendering: [ImageComment]())

        await loader.completeCommentsLoading(with: [comment], at: 0)
        expect(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoading(with: [], at: 1)
        expect(sut, isRendering: [ImageComment]())
    }

    @Test func `Load comments completion does not alter current rendering state on error`() async {
        let comment = makeComment()
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        await loader.completeCommentsLoading(with: [comment], at: 0)
        expect(sut, isRendering: [comment])

        sut.simulateUserInitiatedReload()
        await loader.completeCommentsLoadingWithError(at: 1)
        expect(sut, isRendering: [comment])
    }

    @Test func `Load comments completion renders error message on error until next reload`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()

        #expect(sut.errorMessage == nil)

        await loader.completeCommentsLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateUserInitiatedReload()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Tap on error view hides error message`() async {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        #expect(sut.errorMessage == nil)

        await loader.completeCommentsLoadingWithError(at: 0)
        #expect(sut.errorMessage == loadError)

        sut.simulateErrorViewTap()
        #expect(sut.errorMessage == nil)
    }

    @Test func `Deinit cancels running request`() async {
        let loader = LoaderSpy()
        var sut: ListViewController?

        autoreleasepool {
            sut = CommentsUIComposer.commentsComposedWith(commentsLoader: { try await loader.loadComments() })
            sut?.simulateAppearance()
        }

        #expect(await loader.cancelledRequestsCount == 0)

        sut = nil
        #expect(await loader.cancelledRequestsCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: { try await loader.loadComments() })

        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }

    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        // Days ago, so the relative date reads the same when rendered and when checked.
        ImageComment(id: UUID(), message: message, createdAt: Date().adding(days: -3), username: username)
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

    /// Every read and completion first lets the UI's loading task run, then
    /// completions let the UI handle the result before the test carries on.
    @MainActor
    private final class LoaderSpy {
        private let requests = PendingRequests<[ImageComment]>()

        var loadCommentsCallCount: Int {
            get async {
                await settle()
                return requests.count
            }
        }

        var cancelledRequestsCount: Int {
            get async {
                await settle()
                return requests.cancelledIndices.count
            }
        }

        func loadComments() async throws -> [ImageComment] {
            try await requests.load()
        }

        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) async {
            await settle()
            requests.complete(with: comments, at: index)
            await settle()
        }

        func completeCommentsLoadingWithError(at index: Int) async {
            await settle()
            requests.fail(with: NSError(domain: "an error", code: 0), at: index)
            await settle()
        }
    }
}
