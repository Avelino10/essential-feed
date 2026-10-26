//
//  ImageCommentsEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 15/01/2022.
//

import EssentialFeed
import Foundation
import Testing

struct ImageCommentsEndpointTests {
    @Test func `Image comments endpoint URL`() {
        let imageID = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        let baseURL = URL(string: "http://base-url.com")!

        let received = ImageCommentsEndpoint.get(imageID).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/image/2239CBA2-CB35-4392-ADC0-24A37D38E010/comments")!

        #expect(received == expected)
    }
}
