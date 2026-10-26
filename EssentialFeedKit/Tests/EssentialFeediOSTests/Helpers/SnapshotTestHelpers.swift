//
//  SnapshotTestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Avelino Rodrigues on 06/12/2021.
//

import Foundation
import Testing
import UIKit

/// Compares `snapshot` with the stored `snapshots/<name>.png` next to the calling test file.
/// On a mismatch, the new and stored PNGs are attached to the test result.
func expect(snapshot: UIImage, named name: String, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
    let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
    let snapshotURL = makeSnapshotURL(named: name, filePath: filePath)

    guard let snapshotData = makeSnapshotData(for: snapshot, sourceLocation: sourceLocation) else { return }

    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
        Issue.record("Failed to load stored snapshot at URL: \(snapshotURL). Use `record(snapshot:named:)` to store a snapshot before comparing.", sourceLocation: sourceLocation)
        return
    }

    if snapshotData != storedSnapshotData {
        let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(snapshotURL.lastPathComponent)

        try? snapshotData.write(to: temporarySnapshotURL)

        Attachment.record(snapshotData, named: "\(name)_new.png", sourceLocation: sourceLocation)
        Attachment.record(storedSnapshotData, named: "\(name)_stored.png", sourceLocation: sourceLocation)
        Issue.record("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", sourceLocation: sourceLocation)
    }
}

/// Writes `snapshot` to `snapshots/<name>.png` next to the calling test file, then fails
/// the test so the recording call isn't left in place by accident.
func record(snapshot: UIImage, named name: String, fileID: String = #fileID, filePath: String = #filePath, line: Int = #line, column: Int = #column) {
    let sourceLocation = SourceLocation(fileID: fileID, filePath: filePath, line: line, column: column)
    let snapshotURL = makeSnapshotURL(named: name, filePath: filePath)

    guard let snapshotData = makeSnapshotData(for: snapshot, sourceLocation: sourceLocation) else { return }

    do {
        try FileManager.default.createDirectory(
            at: snapshotURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try snapshotData.write(to: snapshotURL)
        Issue.record("Record succeeded - use `expect(snapshot:named:)` to compare the snapshot from now on.", sourceLocation: sourceLocation)
    } catch {
        Issue.record(error, "Failed to record snapshot", sourceLocation: sourceLocation)
    }
}

private func makeSnapshotURL(named name: String, filePath: String) -> URL {
    return URL(fileURLWithPath: filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("snapshots")
        .appendingPathComponent("\(name).png")
}

private func makeSnapshotData(for snapshot: UIImage, sourceLocation: SourceLocation) -> Data? {
    guard let data = snapshot.pngData() else {
        Issue.record("Failed to generate PNG data representation from snapshot", sourceLocation: sourceLocation)
        return nil
    }

    return data
}
