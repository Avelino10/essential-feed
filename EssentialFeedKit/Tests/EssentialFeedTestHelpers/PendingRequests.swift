//
//  PendingRequests.swift
//  EssentialFeedTestHelpers
//
//  Created by Avelino Rodrigues on 27/10/2026.
//

/// Async requests a test completes on demand. Each `load()` suspends until the test
/// completes or fails it, or until the requesting task is cancelled.
@MainActor
public final class PendingRequests<Value: Sendable> {
    private var continuations = [CheckedContinuation<Value, Error>?]()
    public private(set) var cancelledIndices = [Int]()

    public init() {}

    public var count: Int {
        continuations.count
    }

    public func load() async throws -> Value {
        let index = continuations.count
        continuations.append(nil)

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                if cancelledIndices.contains(index) {
                    continuation.resume(throwing: CancellationError())
                } else {
                    continuations[index] = continuation
                }
            }
        } onCancel: {
            // The UI under test cancels its tasks from the main actor.
            MainActor.assumeIsolated {
                cancel(at: index)
            }
        }
    }

    public func complete(with value: Value, at index: Int) {
        resume(at: index, with: .success(value))
    }

    public func fail(with error: Error, at index: Int) {
        resume(at: index, with: .failure(error))
    }

    private func cancel(at index: Int) {
        cancelledIndices.append(index)
        resume(at: index, with: .failure(CancellationError()))
    }

    /// Leaves requests that were already completed or cancelled alone.
    private func resume(at index: Int, with result: Result<Value, Error>) {
        continuations[index]?.resume(with: result)
        continuations[index] = nil
    }
}

/// Gives main-actor work the code under test just started, such as a loading `Task`,
/// a chance to run before the test carries on.
@MainActor
public func settle() async {
    for _ in 0..<10 {
        await Task.yield()
    }
}
