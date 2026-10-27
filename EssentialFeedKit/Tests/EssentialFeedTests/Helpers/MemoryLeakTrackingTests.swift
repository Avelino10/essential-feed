//
//  MemoryLeakTrackingTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 23/10/2026.
//

import EssentialFeedTestHelpers
import Synchronization
import Testing

struct MemoryLeakTrackingTests {
    @Test func `Tracker does not report deallocated instances`() async {
        let tracker = MemoryLeakTracker()
        var instance: AnyObject? = Instance()
        tracker.track(instance!)

        instance = nil

        await tracker.verifyNoLeaks()
    }

    @Test func `Tracker does not report instances deallocated within the grace period`() async {
        let tracker = MemoryLeakTracker()
        let holder = Holder(Instance())
        tracker.track(holder.instance!)

        Task {
            try? await Task.sleep(for: .milliseconds(20))
            holder.release()
        }

        await tracker.verifyNoLeaks(within: .seconds(1))
    }

    @Test func `Tracker reports instances that are still alive`() async {
        let tracker = MemoryLeakTracker()
        let instance = Instance()
        tracker.track(instance)

        await withKnownIssue {
            await tracker.verifyNoLeaks(within: .zero)
        }

        withExtendedLifetime(instance) {}
    }

    @Test(.trackingMemoryLeaks) func `Trait verifies instances tracked during the test`() {
        trackForMemoryLeaks(Instance())
    }

    @Test func `Tracking without the trait records an issue`() {
        withKnownIssue {
            trackForMemoryLeaks(Instance())
        }
    }

    // MARK: - Helpers

    private final class Instance: Sendable {}

    private final class Holder: Sendable {
        private let storage: Mutex<Instance?>

        init(_ instance: Instance) {
            storage = Mutex(instance)
        }

        var instance: Instance? {
            storage.withLock { $0 }
        }

        func release() {
            storage.withLock { $0 = nil }
        }
    }
}
