//
//  SharedTestHelpers.swift
//  EssentialFeedTestHelpers
//
//  Created by Avelino Rodrigues on 19/07/2021.
//

import Foundation

public func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

public func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

public func anyData() -> Data {
    Data("any data".utf8)
}

public func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    public convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    public func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }

    public func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    public func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
}
