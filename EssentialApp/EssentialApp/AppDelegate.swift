//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Avelino Rodrigues on 09/09/2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)

        #if DEBUG
            configuration.delegateClass = DebuggingSceneDelegate.self
        #endif

        return configuration
    }
}
