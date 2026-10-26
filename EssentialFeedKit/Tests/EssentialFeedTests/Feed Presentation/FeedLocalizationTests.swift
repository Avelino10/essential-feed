//
//  FeedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 23/08/2021.
//

@testable import EssentialFeed
import Foundation
import Testing

struct FeedLocalizationTests {
    @Test func `Localized strings have keys and values for all supported localizations`() {
        let table = "Feed"
        let bundle = Bundle.essentialFeed

        expectLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
