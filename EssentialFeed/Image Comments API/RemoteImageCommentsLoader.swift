//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 13/11/2021.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}
