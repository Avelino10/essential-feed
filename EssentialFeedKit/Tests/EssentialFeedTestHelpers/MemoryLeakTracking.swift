//
//  MemoryLeakTracking.swift
//  EssentialFeedTestHelpers
//
//  Created by Avelino Rodrigues on 23/10/2026.
//

import Synchronization
import Testing

/// Records an issue for every tracked instance that is still alive when `verifyNoLeaks()` runs.
public final class MemoryLeakTracker: Sendable {
    private struct TrackedInstance {
        weak var instance: AnyObject?
        let typeName: String
        let sourceLocation: SourceLocation
    }

    @TaskLocal static var current: MemoryLeakTracker?

    private let trackedInstances = Mutex<[TrackedInstance]>([])

    public init() {}

    public func track(_ instance: AnyObject, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
        let trackedInstance = TrackedInstance(
            instance: instance,
            typeName: String(describing: type(of: instance)),
            sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))

        trackedInstances.withLock { $0.append(trackedInstance) }
    }

    public func verifyNoLeaks() {
        let leakedInstances = trackedInstances.withLock { instances in
            instances.filter { $0.instance != nil }
        }

        for leakedInstance in leakedInstances {
            Issue.record(
                "\(leakedInstance.typeName) should have been deallocated. Potential memory leak.",
                sourceLocation: leakedInstance.sourceLocation)
        }
    }
}

/// Wraps each test in its own `MemoryLeakTracker`, verified once the test body returns.
public struct MemoryLeakTrackingTrait: TestTrait, SuiteTrait, TestScoping {
    public var isRecursive: Bool { true }

    public func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
        testCase == nil ? nil : self
    }

    public func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
        let tracker = MemoryLeakTracker()
        try await MemoryLeakTracker.$current.withValue(tracker) {
            try await function()
        }
        tracker.verifyNoLeaks()
    }
}

extension Trait where Self == MemoryLeakTrackingTrait {
    /// Reports instances passed to `trackForMemoryLeaks(_:)` that outlive the test.
    public static var trackingMemoryLeaks: Self { Self() }
}

/// Expects `instance` to be deallocated by the end of the current test.
/// The test, or its suite, needs the `.trackingMemoryLeaks` trait.
public func trackForMemoryLeaks(_ instance: AnyObject, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
    guard let tracker = MemoryLeakTracker.current else {
        Issue.record(
            "trackForMemoryLeaks(_:) needs the .trackingMemoryLeaks trait on the test or its suite.",
            sourceLocation: SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column))
        return
    }

    tracker.track(instance, fileID: fileID, filePath: filePath, line: line, column: column)
}
