//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/12/2021.
//

@testable import EssentialFeed
import XCTest

class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSuportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle.essentialFeed
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
