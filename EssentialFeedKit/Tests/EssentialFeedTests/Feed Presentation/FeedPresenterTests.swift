//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Testing

struct FeedPresenterTests {
    @Test func `Title is localized`() {
        #expect(FeedPresenter.title == localized("FEED_VIEW_TITLE", table: "Feed"))
    }

    @Test func `Map creates view model`() {
        let feed = uniqueImageFeed().models

        let viewModel = FeedPresenter.map(feed)

        #expect(viewModel.feed == feed)
    }
}
