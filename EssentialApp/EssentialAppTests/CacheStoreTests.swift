//
//  CacheStoreTests.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 30/10/2026.
//

@testable import EssentialApp
import EssentialFeed
import Foundation
import Testing

struct CacheStoreTests {
    @Test(arguments: [
        [],
        ["-store"],
        ["-store", "unknown"],
        ["-other", "swiftdata"],
    ])
    func `Defaults to Core Data when no supported store is requested`(launchArguments: [String]) {
        #expect(CacheStore(launchArguments: launchArguments) == .coreData)
    }

    @Test(arguments: [
        (["-store", "coredata"], CacheStore.coreData),
        (["-store", "swiftdata"], .swiftData),
        (["-store", "SwiftData"], .swiftData),
        (["-other", "value", "-store", "swiftdata"], .swiftData),
    ])
    func `Selects the store named by the store launch argument`(launchArguments: [String], expected: CacheStore) {
        #expect(CacheStore(launchArguments: launchArguments) == expected)
    }

    @Test func `Makes the selected store`() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(CacheStoreTests.self)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        #expect(try CacheStore.coreData.make(in: directory) is CoreDataFeedStore)
        #expect(try CacheStore.swiftData.make(in: directory) is SwiftDataFeedStore)
    }
}
