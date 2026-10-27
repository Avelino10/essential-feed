//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 08/01/2022.
//

import EssentialFeed
import EssentialFeediOS
import UIKit

@MainActor
public final class CommentsUIComposer {
    private init() {}

    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommmentsViewAdapter>

    public static func commentsComposedWith(
        commentsLoader: @escaping () async throws -> [ImageComment]
    ) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)

        let commentsViewController = makeCommentsViewController(title: ImageCommentsPresenter.title)
        commentsViewController.onRefresh = presentationAdapter.loadResource

        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommmentsViewAdapter(controller: commentsViewController),
            loadingView: WeakRefVirtualProxy(commentsViewController),
            errorView: WeakRefVirtualProxy(commentsViewController),
            mapper: { ImageCommentsPresenter.map($0) })

        return commentsViewController
    }

    private static func makeCommentsViewController(title: String) -> ListViewController {
        let controller = ListViewController()
        controller.title = title

        return controller
    }
}

final class CommmentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellController(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}
