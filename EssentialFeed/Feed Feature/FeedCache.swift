//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 15/09/2021.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
