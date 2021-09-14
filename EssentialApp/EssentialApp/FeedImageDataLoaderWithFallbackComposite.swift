//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 14/09/2021.
//

import EssentialFeed
import Foundation

public class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader

    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapper: FeedImageDataLoaderTask?

        func cancel() {
            wrapper?.cancel()
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()

        task.wrapper = primary.loadImageData(from: url) { [weak self] result in
            switch result {
                case .success:
                    completion(result)
                case .failure:
                    task.wrapper = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }

        return task
    }
}
