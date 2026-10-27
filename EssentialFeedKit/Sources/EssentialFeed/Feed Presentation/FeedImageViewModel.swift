//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import Foundation

public struct FeedImageViewModel: Sendable {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        location != nil
    }
}
