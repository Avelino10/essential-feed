//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 16/12/2021.
//

import UIKit

public struct CellController {
    nonisolated let id: any Hashable & Sendable
    let dataSource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let dataSourcePrefetching: UITableViewDataSourcePrefetching?

    public init(id: some Hashable & Sendable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.dataSource = dataSource
        delegate = dataSource as? UITableViewDelegate
        dataSourcePrefetching = dataSource as? UITableViewDataSourcePrefetching
    }
}

// Identity only uses the immutable `id`, so it works from any isolation, as the
// diffable data source requires of its item identifiers.
extension CellController: nonisolated Equatable {
    public nonisolated static func == (lhs: CellController, rhs: CellController) -> Bool {
        AnyHashable(lhs.id) == AnyHashable(rhs.id)
    }
}

extension CellController: nonisolated Hashable {
    public nonisolated func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
