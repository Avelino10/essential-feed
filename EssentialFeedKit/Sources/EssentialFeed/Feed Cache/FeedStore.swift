//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 05/07/2021.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieve() throws -> CachedFeed?
}
