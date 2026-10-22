//
//  Bundle+EssentialFeed.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 22/10/2026.
//

import Foundation

extension Bundle {
    /// The bundle holding EssentialFeed's localized strings and Core Data model.
    /// Tests reach it through `@testable import`, where a bare `Bundle.module`
    /// would read as the test target's own bundle.
    static var essentialFeed: Bundle {
        .module
    }
}
