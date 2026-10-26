//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 29/11/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Testing

@Suite(.trackingMemoryLeaks)
struct LoadResourcePresenterTests {
    @Test func `Init does not deliver messages`() {
        let (_, view) = makeSUT()

        #expect(view.messages.isEmpty, "Expected no view messages")
    }

    @Test func `Did start loading displays no error message and starts loading`() {
        let (sut, view) = makeSUT()

        sut.didStartLoading()

        #expect(view.messages == [
            .display(errorMessage: .none),
            .display(isLoading: true),
        ])
    }

    @Test func `Did finish loading resource displays resource and stops loading`() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })

        sut.didFinishLoading(with: "resource")

        #expect(view.messages == [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false),
        ])
    }

    @Test func `Did finish loading with mapper error displays localized error message and stops loading`() {
        let (sut, view) = makeSUT(mapper: { _ in
            throw anyNSError()
        })

        sut.didFinishLoading(with: "resource")

        #expect(view.messages == [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR", table: "Shared")),
            .display(isLoading: false),
        ])
    }

    @Test func `Did finish loading with error displays localized error message and stops loading`() {
        let (sut, view) = makeSUT()

        sut.didFinishLoading(with: anyNSError())

        #expect(view.messages == [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR", table: "Shared")),
            .display(isLoading: false),
        ])
    }

    // MARK: - Helpers

    private typealias SUT = LoadResourcePresenter<String, ViewSpy>

    private func makeSUT(mapper: @escaping SUT.Mapper = { _ in "any" }) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, errorView: view, mapper: mapper)

        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)

        return (sut, view)
    }

    private class ViewSpy: ResourceView, ResourceLoadingView, ResourceErrorView {
        typealias ResourceViewModel = String
        enum Message: Hashable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resourceViewModel: String)
        }

        private(set) var messages = Set<Message>()

        func display(_ viewModel: ResourceErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: String) {
            messages.insert(.display(resourceViewModel: viewModel))
        }
    }
}
