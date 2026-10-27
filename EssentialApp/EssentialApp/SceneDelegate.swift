//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 09/09/2021.
//

import CoreData
import EssentialFeed
import EssentialFeediOS
import os
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var logger = Logger(subsystem: "com.avelino.EssentialFeed", category: "main")

    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()

    private lazy var navigationController = UINavigationController(rootViewController: makeFeedViewController())

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: { Date() })
    }()

    private lazy var feedLoaders = FeedLoaders(
        httpClient: httpClient,
        localFeedLoader: localFeedLoader,
        localImageLoader: LocalFeedImageDataLoader(store: store),
        baseURL: baseURL)

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    /// The cache validation started when the scene last resigned active.
    private(set) var cacheValidation: Task<Void, Never>?

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)

        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        cacheValidation = Task {
            do {
                try await localFeedLoader.validateCache()
            } catch {
                logger.error("Failed to validate cache with error \(error.localizedDescription)")
            }
        }
    }

    private func makeFeedViewController() -> ListViewController {
        FeedUIComposer.feedComposedWith(
            feedLoader: { [feedLoaders] in try await feedLoaders.loadFirstPage() },
            imageLoader: { [feedLoaders] in try await feedLoaders.loadImageData(from: $0) },
            // Strong on purpose: the screens keep the composition, and its navigation
            // controller, alive. The scene delegate lives as long as its scene anyway.
            selection: { self.showComments(for: $0) })
    }

    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }

    private func makeRemoteCommentsLoader(url: URL) -> () async throws -> [ImageComment] {
        return { [feedLoaders] in
            try await feedLoaders.loadComments(from: url)
        }
    }
}
