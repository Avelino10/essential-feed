//
//  SwiftDataFeedModels.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/10/2026.
//

import Foundation
import SwiftData

@Model
final class SwiftDataFeedCache {
    var timestamp: Date

    @Relationship(deleteRule: .cascade, inverse: \SwiftDataFeedImage.cache)
    var feed: [SwiftDataFeedImage]

    init(timestamp: Date, feed: [SwiftDataFeedImage]) {
        self.timestamp = timestamp
        self.feed = feed
    }

    var localFeed: [LocalFeedImage] {
        feed.sorted { $0.position < $1.position }.map(\.local)
    }
}

@Model
final class SwiftDataFeedImage {
    var id: UUID
    var imageDescription: String?
    var location: String?
    var url: URL
    var data: Data?
    /// SwiftData doesn't keep the order of to-many relationships, so each image keeps its own.
    var position: Int
    var cache: SwiftDataFeedCache?

    init(_ local: LocalFeedImage, position: Int) {
        id = local.id
        imageDescription = local.description
        location = local.location
        url = local.url
        self.position = position
    }

    var local: LocalFeedImage {
        LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
    }
}
