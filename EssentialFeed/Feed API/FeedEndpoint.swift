//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 15/01/2022.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
            case .get:
                return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
