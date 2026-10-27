//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 12/06/2021.
//

import Foundation

public protocol HTTPClient: Sendable {
    /// Cancel in-flight work by cancelling the enclosing `Task`.
    func get(from url: URL) async throws -> (Data, HTTPURLResponse)
}
