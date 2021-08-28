//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
    }
}

class FeedPresenterTests: XCTestCase {
    func test_init_doesNotDeliverMessages() {
        let view = ViewSpy()

        _ = FeedPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    // MARK: - Helpers

    private class ViewSpy {
        let messages = [Any]()
    }
}
