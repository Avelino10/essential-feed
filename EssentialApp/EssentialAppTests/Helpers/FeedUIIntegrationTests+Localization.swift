//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 23/08/2021.
//

import EssentialFeed
import Foundation
import XCTest

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }

    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }

    var feedTitle: String {
        FeedPresenter.title
    }
}
