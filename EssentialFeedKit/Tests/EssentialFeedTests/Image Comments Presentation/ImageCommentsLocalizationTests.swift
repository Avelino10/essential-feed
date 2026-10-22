//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 03/12/2021.
//

import EssentialFeed
import XCTest

class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSuportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
