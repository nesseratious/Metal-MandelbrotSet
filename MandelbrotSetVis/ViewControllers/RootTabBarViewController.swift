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
    
    /// A MandelbrotViewController that shows the mandelbrot set using the MetalRenderer.
    let metalViewController: UIViewController = {
        let metalVC = MandelbrotViewController(renderer: MetalRenderer())
        let image = UIImage(systemName: "cpu")
        metalVC.tabBarItem = UITabBarItem(title: "GPU/METAL", image: image, tag: 0)
        return metalVC
    }()
    
    /// A MandelbrotViewController that shows the mandelbrot set using the AccelerateRenderer.
    let accelerateViewController: UIViewController = {
        let accelerateVC = MandelbrotViewController(renderer: AccelerateRenderer())
        let image = UIImage(systemName: "memorychip")
        accelerateVC.tabBarItem = UITabBarItem(title: "CPU/ACCELERATE", image: image, tag: 1)
        return accelerateVC
    }()
}
