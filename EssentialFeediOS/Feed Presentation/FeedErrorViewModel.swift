//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?

    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
