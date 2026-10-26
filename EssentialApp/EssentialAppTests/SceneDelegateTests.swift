//
//  SceneDelegateTests.swift
//  EssentialAppTests
//
//  Created by Avelino Rodrigues on 29/10/2021.
//

@testable import EssentialApp
import EssentialFeediOS
import Testing
import UIKit

@MainActor
struct SceneDelegateTests {
    @Test func `Configure window sets window as key and visible`() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        #expect(window.makeKeyAndVisibleCallCount == 1, "Expected window to be the key window")
    }

    @Test func `Configure window configures root view controller`() throws {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = try #require(root as? UINavigationController, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        let topController = rootNavigation.topViewController
        #expect(topController is ListViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }
}

private class UIWindowSpy: UIWindow {
    var makeKeyAndVisibleCallCount = 0

    override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
    }
}
