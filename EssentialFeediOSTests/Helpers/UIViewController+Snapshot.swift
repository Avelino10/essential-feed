//
//  UIViewController+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 06/12/2021.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traits: (inout UIMutableTraits) -> Void

    static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 402, height: 874),
            safeAreaInsets: UIEdgeInsets(top: 62, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 62, left: 16, bottom: 34, right: 16),
            traits: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = contentSize
                traits.userInterfaceIdiom = .phone
                traits.horizontalSizeClass = .compact
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            })
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        layoutMargins = configuration.layoutMargins
        rootViewController = root
        isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        return super.traitCollection.modifyingTraits(configuration.traits)
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
