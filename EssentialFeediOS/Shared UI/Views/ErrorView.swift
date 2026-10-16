//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 28/08/2021.
//

import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { return isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }

    public var onHide: (() -> Void)?
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configure() {
        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration

        configurationUpdateHandler = { button in
            button.configuration?.titleTextAttributesTransformer = .messageAttributes(
                font: .preferredFont(forTextStyle: .body, compatibleWith: button.traitCollection))
        }
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _: UITraitCollection) in
            self.setNeedsUpdateConfiguration()
        }

        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }

    private var isVisible: Bool {
        return alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        configuration?.title = message
        configuration?.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }

    private func hideMessage() {
        configuration?.title = nil
        configuration?.contentInsets = .zero
        alpha = 0

        onHide?()
    }
}

private extension UIConfigurationTextAttributesTransformer {
    static func messageAttributes(font: UIFont) -> Self {
        Self { attributes in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            var attributes = attributes
            attributes.font = font
            attributes.merge(AttributeContainer([.paragraphStyle: paragraphStyle]))
            return attributes
        }
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
