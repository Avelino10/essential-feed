//
//  ResourceErrorView.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 03/12/2021.
//

import Foundation

@MainActor
public protocol ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel)
}
