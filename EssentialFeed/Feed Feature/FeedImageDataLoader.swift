//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
