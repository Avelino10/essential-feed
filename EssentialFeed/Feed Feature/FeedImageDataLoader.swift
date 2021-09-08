//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
