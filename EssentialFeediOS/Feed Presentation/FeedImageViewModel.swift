//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 19/08/2021.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        location != nil
    }
}
