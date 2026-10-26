//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 03/12/2021.
//

import EssentialFeed
import EssentialFeedTestHelpers
import Foundation
import Testing

struct ImageCommentsPresenterTests {
    @Test func `Title is localized`() {
        #expect(ImageCommentsPresenter.title == localized("IMAGE_COMMENTS_VIEW_TITLE", table: "ImageComments"))
    }

    @Test func `Map creates view model`() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")

        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: now.adding(minutes: -5, calendar: calendar),
                username: "a username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: now.adding(days: -1, calendar: calendar),
                username: "another username"),
        ]

        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )

        #expect(viewModel.comments == [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "a username"
            ),
            ImageCommentViewModel(
                message: "another message",
                date: "1 day ago",
                username: "another username"
            ),
        ])
    }
}
