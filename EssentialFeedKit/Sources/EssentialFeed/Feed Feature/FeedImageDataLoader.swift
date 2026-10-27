//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import Foundation

public protocol FeedImageDataLoader: Sendable {
    func loadImageData(from url: URL) async throws -> Data
}
