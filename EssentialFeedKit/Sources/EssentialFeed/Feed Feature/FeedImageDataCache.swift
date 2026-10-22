//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 15/09/2021.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}
