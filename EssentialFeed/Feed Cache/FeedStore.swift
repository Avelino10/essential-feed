//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 05/07/2021.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionError = Error?
    typealias DeletionCompletion = (DeletionError) -> Void

    typealias InsertionError = Error?
    typealias InsertionCompletion = (InsertionError) -> Void

    typealias RetrievalResult  = Result<CachedFeed?, Error>

    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
