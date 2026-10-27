//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Avelino Rodrigues on 23/08/2021.
//

import EssentialFeed
import EssentialFeediOS

@MainActor
final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private let loader: () async throws -> Resource
    // Only used on the main actor, and by deinit once nothing else can reach the adapter.
    nonisolated(unsafe) private var loading: Task<Void, Never>?
    var presenter: LoadResourcePresenter<Resource, View>?

    init(loader: @escaping () async throws -> Resource) {
        self.loader = loader
    }

    deinit {
        loading?.cancel()
    }

    func loadResource() {
        guard loading == nil else { return }

        presenter?.didStartLoading()

        let loader = self.loader
        loading = Task { [weak self] in
            do {
                let resource = try await loader()
                guard !Task.isCancelled else { return }
                self?.presenter?.didFinishLoading(with: resource)
            } catch {
                guard !Task.isCancelled else { return }
                self?.presenter?.didFinishLoading(with: error)
            }
            self?.loading = nil
        }
    }

    func cancel() {
        loading?.cancel()
        loading = nil
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }

    func didCancelRequestImage() {
        cancel()
    }
}
