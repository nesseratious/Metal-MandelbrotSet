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
    
    /// Holds this view controller's transformation of the mandelbrot set.
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
    
    /// Adds gestures to pan and zoom mandelbrot view.
    private func addGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        panGesture.allowedScrollTypesMask = [.continuous]
        renderer.addGestureRecognizer(pinchGesture)
        renderer.addGestureRecognizer(panGesture)
    }
    
    /// Calculates aspect ratio of the first frame and writes it to the renderer's bridge buffer.
    /// Runs only once when the vc is first opened.
    private func calculateAspectRatio() {
        let scaleMultiplier: Float = 1.15
        let width = Float(view.frame.width)
        let height = Float(view.frame.height)
        renderer.buffer.aspectRatio.x = scaleMultiplier
        renderer.buffer.aspectRatio.y = height / width * scaleMultiplier
    }
}

@objc private extension MandelbrotViewController {
    func pan(sender: UIPanGestureRecognizer) {
        guard sender.view != nil else { return }
        
        /// The amount of pixels of the mandelbrot that should corespond to one point in gesture's translation.
        /// Pixel is one mandelbrot unit of calculation (doesn't reflect actual pixels on screen), point is UIKit point.
        /// Modifing this value will change sensitivity of the pan gesture.
        /// The default is 1 point = 175 pixels.
        let pixelsPerPoint: CGFloat = 175
        
        let deltaX = Float(sender.translation(in: view).x / view.frame.width)
        let deltaY = Float(sender.translation(in: view).y / view.frame.height)
        let shiftX = transform.x + deltaX * Float(view.frame.width / pixelsPerPoint) / transform.zoom
        let shiftY = transform.y - deltaY * Float(view.frame.height / pixelsPerPoint) / transform.zoom
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
    
     func zoom(sender: UIPinchGestureRecognizer) {
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
}
