//
//  ResourceErrorViewModel.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?

    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: nil)
    }

    static func error(message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
