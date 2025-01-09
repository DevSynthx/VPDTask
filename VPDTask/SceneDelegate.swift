//
//  VPD_TaskApp.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
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
    
    private func setupDependencies() {
        // Register dependencies
        DependencyContainer.shared.register(NetworkManager.shared as NetworkProtocol)
        DependencyContainer.shared.register(RepositoryService())
    }

    // UIScene configuration
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("UISceen")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}



class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: scene called") // Add this debug print
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast windowScene") // Debug guard failure
            return
        }
        
        print("SceneDelegate: Setting up window") // Debug window setup
        let window = UIWindow(windowScene: windowScene)
        
        let homeViewController = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        self.window = window
        print("SceneDelegate: Window setup complete") // Confirm completion
    }
}
