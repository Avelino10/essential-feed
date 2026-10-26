//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/12/2021.
//

@testable import EssentialFeed
import Foundation
import Testing

struct SharedLocalizationTests {
    @Test func `Localized strings have keys and values for all supported localizations`() {
        let table = "Shared"
        let bundle = Bundle.essentialFeed

        expectLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
