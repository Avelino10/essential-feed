//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 20/08/2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
