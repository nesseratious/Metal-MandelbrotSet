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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    let metalViewController: UIViewController = {
        let metalVC = MandelbrotViewController(renderer: MetalRenderer())
        metalVC.tabBarItem = UITabBarItem(title: "GPU/METAL", image: UIImage(systemName: "cpu"), tag: 0)
        return metalVC
    }()
    
    let accelerateViewController: UIViewController = {
        let accelerateVC = MandelbrotViewController(renderer: SwiftAccelerateRenderer())
        accelerateVC.tabBarItem = UITabBarItem(title: "CPU/ACCELERATE", image: UIImage(systemName: "memorychip"), tag: 1)
        return accelerateVC
    }()
}
