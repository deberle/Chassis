//
//  AppDelegate.swift
//  Chassis
//
//  Created by Daniel Eberle on 15.09.20.
//

import UIKit
import CoreData

@main
class AppDelegate: AppModule, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        setupAppModules()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - App Modules

    
    let persistenceController = PersistenceController()
    let router                = Router()

    func setupAppModules() {

        let modules: [AppModule] = [self, self.persistenceController, self.router]

        zip(modules, modules.dropFirst()).forEach {

            $0.nextModule = $1
        }
    }
}


class AppModule: UIResponder {

    var nextModule: AppModule?

    override var next: UIResponder? {

        return self.nextModule
    }
}


