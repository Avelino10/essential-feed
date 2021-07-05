//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 05/07/2021.
//

import Foundation

public protocol FeedStore {
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void

    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
