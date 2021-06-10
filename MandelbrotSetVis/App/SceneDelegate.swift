//
//  SceneDelegate.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/29/20.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = RootTabBarController()
        window?.makeKeyAndVisible()
        
        #if targetEnvironment(macCatalyst)
        scene.titlebar?.toolbar = MacToolbar(titles: ["GPU/METAL", "CPU/ACCELERATE"])
        scene.titlebar?.toolbarStyle = .automatic
        #endif
    }
}
