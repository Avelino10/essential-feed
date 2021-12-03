//
//  ImageCommentsPresenter.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 03/12/2021.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                          tableName: "ImageComments",
                          bundle: Bundle(for: Self.self),
                          comment: "Title for the image comments view")
    }
}
