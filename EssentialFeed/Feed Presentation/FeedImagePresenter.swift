//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
