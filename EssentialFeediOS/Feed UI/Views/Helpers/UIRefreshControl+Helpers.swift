//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
