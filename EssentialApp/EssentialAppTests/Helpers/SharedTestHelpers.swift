//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 14/09/2021.
//

import EssentialFeed

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
