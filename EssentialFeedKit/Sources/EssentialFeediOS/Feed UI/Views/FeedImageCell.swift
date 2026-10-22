//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 17/08/2021.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    private(set) public lazy var locationContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pinContainer, locationLabel])
        stack.alignment = .top
        stack.spacing = 6
        return stack
    }()

    private(set) public lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.init(251), for: .horizontal)
        label.setContentHuggingPriority(.init(251), for: .vertical)
        return label
    }()

    private(set) public lazy var feedImageContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 22
        container.clipsToBounds = true
        return container
    }()

    private(set) public lazy var feedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = "feed-image-view"
        imageView.setContentHuggingPriority(.init(251), for: .horizontal)
        imageView.setContentHuggingPriority(.init(251), for: .vertical)
        return imageView
    }()

    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("↻", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 60)
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    private(set) public lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.numberOfLines = 6
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.init(251), for: .horizontal)
        label.setContentHuggingPriority(.init(251), for: .vertical)
        return label
    }()

    private lazy var pinContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .systemBackground
        return container
    }()

    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .pin))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.setContentHuggingPriority(.init(251), for: .horizontal)
        imageView.setContentHuggingPriority(.init(251), for: .vertical)
        return imageView
    }()

    var onRetry: (() -> Void)?

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        selectionStyle = .none
        clipsToBounds = true
        accessibilityIdentifier = "feed-image-cell"

        contentView.clipsToBounds = true
        contentView.isOpaque = false
        contentView.preservesSuperviewLayoutMargins = true
        contentView.insetsLayoutMarginsFromSafeArea = false

        pinContainer.addSubview(pinImageView)
        feedImageContainer.addSubview(feedImageView)
        feedImageContainer.addSubview(feedImageRetryButton)

        let stack = UIStackView(arrangedSubviews: [locationContainer, feedImageContainer, descriptionLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        contentView.addSubview(stack)

        [stack, pinImageView, feedImageView, feedImageRetryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let top = stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 6)
        let bottom = contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 6)
        top.priority = .init(999)
        bottom.priority = .init(999)

        NSLayoutConstraint.activate([
            top,
            bottom,
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor),

            locationContainer.widthAnchor.constraint(equalTo: stack.widthAnchor),
            feedImageContainer.widthAnchor.constraint(equalTo: stack.widthAnchor),
            feedImageContainer.widthAnchor.constraint(equalTo: feedImageContainer.heightAnchor),

            pinContainer.widthAnchor.constraint(equalToConstant: 10),
            pinImageView.leadingAnchor.constraint(equalTo: pinContainer.leadingAnchor),
            pinImageView.topAnchor.constraint(equalTo: pinContainer.topAnchor, constant: 3),
            pinImageView.heightAnchor.constraint(equalToConstant: 14),

            feedImageView.leadingAnchor.constraint(equalTo: feedImageContainer.leadingAnchor),
            feedImageView.topAnchor.constraint(equalTo: feedImageContainer.topAnchor),
            feedImageContainer.trailingAnchor.constraint(equalTo: feedImageView.trailingAnchor),
            feedImageContainer.bottomAnchor.constraint(equalTo: feedImageView.bottomAnchor),

            feedImageRetryButton.leadingAnchor.constraint(equalTo: feedImageContainer.leadingAnchor),
            feedImageRetryButton.topAnchor.constraint(equalTo: feedImageContainer.topAnchor),
            feedImageContainer.trailingAnchor.constraint(equalTo: feedImageRetryButton.trailingAnchor),
            feedImageContainer.bottomAnchor.constraint(equalTo: feedImageRetryButton.bottomAnchor),
        ])
    }

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
