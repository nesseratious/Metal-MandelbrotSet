//
//  RootTabBarViewController.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/12/20.
//

import UIKit

final class RootTabBarController: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [metalViewController, accelerateViewController]
        setupTabBar()
        showMacToolbar()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemPink
        tabBar.backgroundColor = .clear
        tabBar.backgroundImage = UIImage()
    }
    
    private func showMacToolbar() {
        /// On macOS we show native NSToolbar instead of iOS's tab bar
        #if targetEnvironment(macCatalyst)
        tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectedIndex(from:)), name: .macToolBarSelectionChanged, object: nil)
        #endif
    }
    
    @objc private func updateSelectedIndex(from notification: Notification) {
        if let index = notification.object as? Int {
            selectedIndex = index
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// A MandelbrotViewController that renders the mandelbrot set using the `MetalRenderer`.
    private let metalViewController: UIViewController = {
        let metalVC = MandelbrotViewController(renderer: MetalRenderer())
        let image = UIImage(systemName: "cpu")
        metalVC.tabBarItem = UITabBarItem(title: "GPU/METAL", image: image, tag: 0)
        return metalVC
    }()
    
    /// A MandelbrotViewController that renders the mandelbrot set using the `AccelerateRenderer`.
    private let accelerateViewController: UIViewController = {
        let accelerateVC = MandelbrotViewController(renderer: AccelerateRenderer())
        let image = UIImage(systemName: "memorychip")
        accelerateVC.tabBarItem = UITabBarItem(title: "CPU/ACCELERATE", image: image, tag: 1)
        return accelerateVC
    }()
}
