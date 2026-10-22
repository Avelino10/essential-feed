//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 15/01/2022.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)

    public func url(baseURL: URL) -> URL {
        switch self {
            case let .get(id):
                return baseURL.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}
