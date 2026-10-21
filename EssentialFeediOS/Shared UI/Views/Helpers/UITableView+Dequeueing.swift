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
        if let cell = dequeueReusableCell(withIdentifier: identifier) as? T {
            return cell
        }

        register(T.self, forCellReuseIdentifier: identifier)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
