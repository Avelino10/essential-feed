//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 14/09/2021.
//

import Foundation

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}
