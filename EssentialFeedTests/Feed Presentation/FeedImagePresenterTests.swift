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
        let view = ViewSpy()

        _ = FeedImagePresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers

    private class ViewSpy {
        let messages = [Any]()
    }
}
