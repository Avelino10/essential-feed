//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 04/06/2021.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
