//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 06/12/2021.
//

import EssentialFeed
import Foundation
import UIKit

public class ImageCommentCellController: NSObject, CellController {
    private let model: ImageCommentViewModel

    public init(model: ImageCommentViewModel) {
        self.model = model
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date

        return cell
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {}
}
