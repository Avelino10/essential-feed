//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import XCTest

private final class FeedImagePresenter {
    init(view: Any) {
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotDeliverMessages() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)

        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, view)
    }

    // MARK: - Helpers

    private class ViewSpy {
        let messages = [Any]()
    }
}
