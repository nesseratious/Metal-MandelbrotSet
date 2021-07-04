//
//  MandelbrotViewController.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

/// A reusable view controller that shows the mandelbrot set using the provided Renderer.
final class MandelbrotViewController: UIViewController {
    private let renderer: Renderer
    
    /// Holds this view controller's transformation of the mandelbrot set.
    private var transform = SIMD2<FloatType>(0, 0)
    private var zoom: FloatType = 1
    
    /// Injects the provided Renderer.
    /// - Parameter renderer: Entity conforming to Renderer protocol, responsible for rendering of the mandelbrot set.
    init(renderer: Renderer) {
        self.renderer = renderer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not accessible from IB.")
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
    
    /// Adds gestures to pan and zoom the mandelbrot view.
    private func addGestures() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoom(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        panGesture.allowedScrollTypesMask = [.continuous] // iPad mouse support
        renderer.addGestureRecognizer(pinchGesture)
        renderer.addGestureRecognizer(panGesture)
    }
    
    /// Calculates aspect ratio of the next frame and writes it to the renderer's bridge buffer.
    private func calculateAspectRatio() {
        
        /// Multiplier for the mandelbrot's scale in inverse percantage of the screen size.
        /// 1.0 is 100% of the screen.
        /// The default is 2.0 (50% of the screen).
        let scaleMultiplier: FloatType = 2.0
        
        let width = FloatType(view.frame.width)
        let height = FloatType(view.frame.height)
        renderer.vertexBuffer.aspectRatio.x = scaleMultiplier
        renderer.vertexBuffer.aspectRatio.y = height / width * scaleMultiplier
    }
}

@objc private extension MandelbrotViewController {
    func pan(sender: UIPanGestureRecognizer) {
        guard sender.view != nil else { return }
        
        /// The amount of pixels of the mandelbrot that should corespond to one point in gesture's translation.
        /// Pixel is one mandelbrot unit of calculation (depends on the size of `FloatType`, doesn't reflect actual pixels on screen), point is UIKit point.
        /// Modifing this value will change sensitivity of the pan gesture.
        /// The default is 1 point = 175 pixels.
        let pixelsPerPoint: FloatType = 175
    
        let location = sender.translation(in: view)
        
        /// If `FloatType` is 64bit it's possible to reinterpret to simd using `unsafeBitCast`, it will be much faster than calling the SIMD constructor.
        let positionVec = SIMD2(FloatType(location.x), FloatType(location.y))
        let sizeVec = SIMD2(FloatType(view.frame.size.width), FloatType(view.frame.size.height))
        
        let delta = positionVec / sizeVec
        let deltaTransform = delta * sizeVec / pixelsPerPoint / zoom * SIMD2<FloatType>(1, -1)
        let newTransform = transform + deltaTransform

        switch sender.state {
        case .began, .changed:
            renderer.vertexBuffer.translation = newTransform
        case .ended:
            transform = newTransform
        default:
            break
        }
    }
    
     func zoom(sender: UIPinchGestureRecognizer) {
        guard sender.view != nil else { return }
        
        let scale = zoom * FloatType(sender.scale)
        switch sender.state {
        case .began, .changed:
            renderer.vertexBuffer.scale = 1.0 / scale
        case .ended:
            zoom = scale
        default:
            break
        }    
    }
}
