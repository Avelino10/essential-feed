//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 15/09/2021.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
