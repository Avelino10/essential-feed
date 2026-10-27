//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 05/07/2021.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    func deleteCachedFeed() async throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) async throws
    func retrieve() async throws -> CachedFeed?
}
