//
//  SharedLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 02/12/2021.
//

import EssentialFeed
import XCTest

class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSuportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

    // MARK: - Helpers

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
