//
//  MemoryLeakTrackingTests.swift
//  EssentialFeedTests
//
//  Created by Avelino Rodrigues on 23/10/2026.
//

import EssentialFeedTestHelpers
import Testing

struct MemoryLeakTrackingTests {
    @Test func `Tracker does not report deallocated instances`() {
        let tracker = MemoryLeakTracker()
        var instance: AnyObject? = Instance()
        tracker.track(instance!)

        instance = nil

        tracker.verifyNoLeaks()
    }

    @Test func `Tracker reports instances that are still alive`() {
        let tracker = MemoryLeakTracker()
        let instance = Instance()
        tracker.track(instance)

        withKnownIssue {
            tracker.verifyNoLeaks()
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

    private final class Instance {}
}
