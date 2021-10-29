//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 18/08/2021.
//

import UIKit

extension UIControl {
    func simulate(event: UIControl.Event) {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        })
    }
}
