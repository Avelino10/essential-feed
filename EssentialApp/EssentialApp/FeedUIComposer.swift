//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import Combine
import EssentialFeed
import EssentialFeediOS
import UIKit

@MainActor
public final class FeedUIComposer {
    private init() {}

    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> AnyPublisher<Data, Error>,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        let feedController = makeFeedViewController(title: FeedPresenter.title)

        feedController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(
                controller: feedController,
                imageLoader: imageLoader,
                selection: selection),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: { $0 })

        return feedController
    }

    private static func makeFeedViewController(title: String) -> ListViewController {
        let feedController = ListViewController()
        feedController.title = title

        return feedController
    }
}
