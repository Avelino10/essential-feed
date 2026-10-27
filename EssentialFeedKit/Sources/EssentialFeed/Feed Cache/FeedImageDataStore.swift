//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import Foundation

public protocol FeedImageDataStore: Sendable {
    func insert(_ data: Data, for url: URL) async throws
    func retrieve(dataForURL url: URL) async throws -> Data?
}
