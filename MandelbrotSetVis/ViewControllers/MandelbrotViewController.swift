//
//  MandelbrotViewController.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

final class MandelbrotViewController: UIViewController {
    private let renderer: Renderer
    private var transform = SceneTransform()
    
    init(renderer: Renderer) {
        self.renderer = renderer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = renderer
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
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        panGesture.allowedScrollTypesMask = [.continuous]
        renderer.addGestureRecognizer(pinchGesture)
        renderer.addGestureRecognizer(panGesture)
    }
    
    private func calculateAspectRatio() {
        let scaleMultiplier: Float = 1.15
        let widht = Float(view.frame.width)
        let height = Float(view.frame.height)
        renderer.buffer.aspectRatio.x = scaleMultiplier
        renderer.buffer.aspectRatio.y = height / widht * scaleMultiplier
    }
}

private extension MandelbrotViewController {
    @objc func zoom(sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else { return }
        let scale = transform.zoom * Float(sender.scale)
        switch sender.state {
        case .began, .changed:
            renderer.buffer.scale = 1.0 / scale
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
            renderer.buffer.translation = (shiftX, shiftY)
        case .ended:
            transform.x = shiftX
            transform.y = shiftY
        default:
            break
        }
    }
}
