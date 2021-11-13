//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 04/06/2021.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
