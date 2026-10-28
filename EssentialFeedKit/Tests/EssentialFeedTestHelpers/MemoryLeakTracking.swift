//
//  MemoryLeakTracking.swift
//  EssentialFeedTestHelpers
//
//  Created by Avelino Rodrigues on 23/10/2026.
//

import Synchronization
import Testing

/// Records an issue for every tracked instance that is still alive when `verifyNoLeaks(within:)` runs.
public final class MemoryLeakTracker: Sendable {
    // Unchecked because of the weak reference: weak loads are thread-safe, and the tracker
    // only reads it to check whether the instance was deallocated, never to use it.
    private struct TrackedInstance: @unchecked Sendable {
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

    /// Instances released through an autorelease pool, or by a task winding down, go away
    /// on a later run loop turn, so they get `gracePeriod` before being reported. The default
    /// is generous because a busy CI runner can stall the main actor for seconds; it only
    /// costs time when something really leaks.
    public func verifyNoLeaks(within gracePeriod: Duration = .seconds(10)) async {
        let deadline = ContinuousClock.now + gracePeriod
        while !leakedInstances().isEmpty, ContinuousClock.now < deadline {
            try? await Task.sleep(for: .milliseconds(5))
        }

        for leakedInstance in leakedInstances() {
            Issue.record(
                "\(leakedInstance.typeName) should have been deallocated. Potential memory leak.",
                sourceLocation: leakedInstance.sourceLocation)
        }
    }

    private func leakedInstances() -> [TrackedInstance] {
        trackedInstances.withLock { instances in
            instances.filter { $0.instance != nil }
        }
    }
}

/// Wraps each test in its own `MemoryLeakTracker`, verified once the test body returns.
public struct MemoryLeakTrackingTrait: TestTrait, SuiteTrait, TestScoping {
    public var isRecursive: Bool { true }

    public func scopeProvider(for test: Test, testCase: Test.Case?) -> Self? {
        testCase == nil ? nil : self
    }

    public func provideScope(for test: Test, testCase: Test.Case?, performing function: @concurrent @Sendable () async throws -> Void) async throws {
        let tracker = MemoryLeakTracker()
        try await MemoryLeakTracker.$current.withValue(tracker) {
            try await function()
        }
        await tracker.verifyNoLeaks()
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
