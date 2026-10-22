//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
