//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Avelino Rodrigues on 03/08/2021.
//

import CoreData

public final class CoreDataFeedStore: Sendable {
    private static let modelName = "FeedStore"
    // A loaded model is immutable, so sharing it between stores is safe.
    nonisolated(unsafe) private static let model = NSManagedObjectModel.with(name: modelName, in: .essentialFeed)

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    /// Runs `action` on the context's queue. Managed objects must not escape `action`:
    /// return value types only.
    func perform<R: Sendable>(_ action: @escaping @Sendable (NSManagedObjectContext) throws -> R) async throws -> R {
        let context = self.context
        return try await context.perform { try action(context) }
    }

    private func cleanUpReferencesToPersistentStores() {
        let coordinator = container.persistentStoreCoordinator
        context.performAndWait {
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}
