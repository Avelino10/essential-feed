//
//  Bundle+EssentialFeed.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 22/10/2026.
//

import Foundation

extension Bundle {
    /// The bundle holding EssentialFeed's localized strings and Core Data model.
    static var essentialFeed: Bundle {
        #if SWIFT_PACKAGE
        .module
        #else
        Bundle(for: BundleToken.self)
        #endif
    }
}

private final class BundleToken {}
