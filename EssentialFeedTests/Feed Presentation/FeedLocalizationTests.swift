//
//  FeedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 23/08/2021.
//

import EssentialFeed
import XCTest

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSuportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)

        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
