//
//  AppDelegate.swift
//  VPDTask
//
//  Created by Inyene on 1/9/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("running")
       setupDependencies()
        print("done")
        return true
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
         print("Discarded scene sessions")
     }
     
    
    private func setupDependencies() {
        // Register dependencies
        DependencyContainer.shared.register(NetworkManager.shared as NetworkProtocol)
        DependencyContainer.shared.register(RepositoryService())
    }

    // UIScene configuration
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("UIScene configuration requested")
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self 
        print("UIScene configuration created")
        return configuration
    }
}
