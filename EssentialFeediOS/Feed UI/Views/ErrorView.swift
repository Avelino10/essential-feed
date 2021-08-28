//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!

    public var message: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        label.text = nil
    }
}
