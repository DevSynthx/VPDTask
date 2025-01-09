//
//  VPD_TaskApp.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Setup code that needs to run when app launches
        setupDependencies()
        return true
    }
    
    private func setupDependencies() {
        // Register your dependencies
        DependencyContainer.shared.register(NetworkManager.shared as NetworkProtocol)
        DependencyContainer.shared.register(RepositoryService())
    }

    // UIScene configuration
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// SceneDelegate.swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window
        let window = UIWindow(windowScene: windowScene)
        
        // Create initial view controller
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        // Set root and make visible
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
