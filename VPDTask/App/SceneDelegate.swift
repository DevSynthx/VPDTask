//
//  VPD_TaskApp.swift
//  VPD Task
//
//  Created by Inyene on 1/8/25.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: scene called")
        
        guard let windowScene = (scene as? UIWindowScene) else {
            print("SceneDelegate: Failed to cast windowScene")
            return
        }
        
        print("SceneDelegate: Setting up window")
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        
        let homeVC = HomeViewController()
        print("Created HomeViewController")
        let navController = UINavigationController(rootViewController: homeVC)
        print("Created NavigationController")
        
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
        
        print("SceneDelegate: Window setup complete")
    }
}
