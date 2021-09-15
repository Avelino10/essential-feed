//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 15/09/2021.
//

import EssentialFeed
import Foundation

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
