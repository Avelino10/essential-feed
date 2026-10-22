//
//  ImageCommentCell.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 06/12/2021.
//

import UIKit

public final class ImageCommentCell: UITableViewCell {
    public private(set) lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.init(251), for: .horizontal)
        label.setContentHuggingPriority(.init(251), for: .vertical)
        return label
    }()

    public private(set) lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.init(252), for: .horizontal)
        label.setContentHuggingPriority(.init(251), for: .vertical)
        label.setContentCompressionResistancePriority(.init(749), for: .horizontal)
        return label
    }()

    public private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.init(251), for: .vertical)
        label.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        return label
    }()

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

        contentView.clipsToBounds = true
        contentView.isOpaque = false
        contentView.preservesSuperviewLayoutMargins = true
        contentView.insetsLayoutMarginsFromSafeArea = false

        let header = UIStackView(arrangedSubviews: [usernameLabel, dateLabel])
        header.alignment = .top
        header.spacing = 8

        let stack = UIStackView(arrangedSubviews: [header, messageLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        contentView.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor),

            header.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: header.trailingAnchor),
        ])
    }
}
