//
//  FeedUIIntegrationTests+Assertions.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
import Testing

extension FeedUIIntegrationTests {
    func expect(_ sut: ListViewController, isRendering feed: [FeedImage], fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
        let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())

        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            Issue.record("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", sourceLocation: sourceLocation)
            return
        }

        for (index, image) in feed.enumerated() {
            expect(sut, hasViewConfiguredFor: image, at: index, sourceLocation: sourceLocation)
        }
    }

    private func expect(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int, sourceLocation: SourceLocation) {
        let view = sut.feedImageView(at: index)

        guard let cell = view as? FeedImageCell else {
            Issue.record("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", sourceLocation: sourceLocation)
            return
        }

        let shouldLocationBeVisible = image.location != nil
        #expect(cell.isShowingLocation == shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", sourceLocation: sourceLocation)

        #expect(cell.locationText == image.location, "Expected location text to be \(String(describing: image.location)) for image view at index (\(index))", sourceLocation: sourceLocation)

        #expect(cell.descriptionText == image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index))", sourceLocation: sourceLocation)
    }
}
