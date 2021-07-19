//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 19/07/2021.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}
