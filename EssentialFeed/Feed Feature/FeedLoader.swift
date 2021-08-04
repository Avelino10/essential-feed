//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 04/06/2021.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
