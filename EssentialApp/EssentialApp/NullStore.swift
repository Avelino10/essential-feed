//
//  NullStore.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 19/02/2022.
//

import EssentialFeed
import Foundation

class NullStore {}

extension NullStore: FeedStore {
    func deleteCachedFeed() throws {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}
    func retrieve() throws -> CachedFeed? { .none }
}

extension NullStore: FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}
