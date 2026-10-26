//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Testing

struct FeedImagePresenterTests {
    @Test func `Map creates view model`() {
        let image = uniqueImage()

        let viewModel = FeedImagePresenter.map(image)

        #expect(viewModel.description == image.description)
        #expect(viewModel.location == image.location)
    }
}
