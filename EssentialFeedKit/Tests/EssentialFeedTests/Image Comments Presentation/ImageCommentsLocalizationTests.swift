//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 03/12/2021.
//

@testable import EssentialFeed
import Foundation
import Testing

struct ImageCommentsLocalizationTests {
    @Test func `Localized strings have keys and values for all supported localizations`() {
        let table = "ImageComments"
        let bundle = Bundle.essentialFeed

        expectLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
