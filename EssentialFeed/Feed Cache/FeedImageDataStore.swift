//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 08/09/2021.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
