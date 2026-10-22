//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTestHelpers
//
//  Created by Avelino Rodrigues on 19/07/2021.
//

import EssentialFeed
import Foundation

public func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

public func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }

    return (models, local)
}

extension Date {
    public func minusFeedCacheMaxAge() -> Date {
        adding(days: -feedCacheMaxAgeInDays)
    }

    private var feedCacheMaxAgeInDays: Int {
        7
    }
}
