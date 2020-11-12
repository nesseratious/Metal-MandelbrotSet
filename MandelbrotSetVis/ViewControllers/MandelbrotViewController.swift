//
//  MandelbrotViewController.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

final class MandelbrotViewController: UIViewController {
    private let renderer: Renderer = MetalRenderer()
    private var transform = SceneTransform()
    
    override func loadView() {
        view = renderer.view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestures()
        renderer.setupRenderer()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calculateAspectRatio()
    }
    
    private func addGestures() {
        let renderView = renderer.view
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        // Enable trackpad support for iPads
        if #available(iOS 13.4, *) {
            panGesture.allowedScrollTypesMask = [.continuous]
        }
        renderView.addGestureRecognizer(pinchGesture)
        renderView.addGestureRecognizer(panGesture)
    }
    
    private func calculateAspectRatio() {
        let scaleMultiplier: Float = 1.15
        let widht = Float(view.frame.width)
        let height = Float(view.frame.height)
        renderer.bridgeBuffer.aspectRatio.x = scaleMultiplier
        renderer.bridgeBuffer.aspectRatio.y = height / widht * scaleMultiplier
    }
}

private extension MandelbrotViewController {
    @objc func zoom(sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else { return }
        let scale = transform.zoom * Float(sender.scale)
        switch sender.state {
        case .began, .changed:
            renderer.bridgeBuffer.scale = 1.0 / scale
        case .ended:
            transform.zoom = scale
        default:
            break
        }
    }

    @objc func pan(sender: UIPanGestureRecognizer) {
        guard sender.view != nil else { return }
        let deltaX = Float(sender.translation(in: view).x/view.frame.width) * Float(view.frame.width / 200)
        let deltaY = Float(sender.translation(in: view).y/view.frame.height) * Float(view.frame.height / 200)
        let shiftX = transform.x + deltaX / transform.zoom
        let shiftY = transform.y - deltaY / transform.zoom
        switch sender.state {
        case .began, .changed:
            renderer.bridgeBuffer.translation = (shiftX, shiftY)
        case .ended:
            transform.x = shiftX
            transform.y = shiftY
        default:
            break
        }
    }
}
