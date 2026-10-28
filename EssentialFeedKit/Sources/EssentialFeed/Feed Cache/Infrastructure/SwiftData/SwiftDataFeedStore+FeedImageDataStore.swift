//
//  SwiftDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/10/2026.
//

import Foundation
import SwiftData

extension SwiftDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL) throws {
        guard let image = try image(with: url) else { return }

        image.data = data
        try modelContext.save()
    }

    public func retrieve(dataForURL url: URL) throws -> Data? {
        try image(with: url)?.data
    }

    private func image(with url: URL) throws -> SwiftDataFeedImage? {
        var descriptor = FetchDescriptor<SwiftDataFeedImage>(predicate: #Predicate { $0.url == url })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
