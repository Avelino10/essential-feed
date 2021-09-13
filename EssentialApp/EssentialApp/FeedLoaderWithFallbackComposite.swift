//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 13/09/2021.
//

import EssentialFeed
import Foundation

public class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader

    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
                case .success:
                    completion(result)
                case .failure:
                    self?.fallback.load(completion: completion)
            }
        }
    }
}
