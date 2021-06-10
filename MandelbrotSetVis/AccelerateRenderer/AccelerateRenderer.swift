//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit

/// View with mandelbrot image rendered using the power of CPU.
final class AccelerateRenderer: UIView {
    private var bridgeBuffer = RendererBuffer()
    private let mandelbrotImage = UIImageView()
    private var performanceMonitor = PerformanceMonitor()
    private lazy var image = MandelbrotImage(for: self)
    private lazy var contextProvider = ContextProvider(of: image)
    
    /// Starts the mandelbrot render process.
    private func render() {
        guard !performanceMonitor.isRunning else { return }
        performanceMonitor.calculationStarted(on: .CPU)
        let buffer = contextProvider.makeBuffer()
        
        async(priority: .userInteractive) {
            await calculateMandelbrot(in: buffer, contextProvider: contextProvider)
            mandelbrotImage.image = contextProvider.generateUIImage()
            performanceMonitor.calculationEnded()
        }
    }

    private func calculateMandelbrot(in buffer: UnsafeMutablePointer<UInt32>, contextProvider: ContextProvider) async {
        let bufferProvider = TransformBufferProvider(with: contextProvider, bridgeBuffer: bridgeBuffer)
        async let widthBuffer = bufferProvider.makeWidthBuffer()
        async let heightBuffer = bufferProvider.makeHeightBuffer()
        let matrix = await Matrix(width: widthBuffer, heigh: heightBuffer)
        calculate(target: buffer, image: contextProvider.image, transform: matrix)
    }
    
    private func calculate(target: UnsafeMutablePointer<UInt32>, image: MandelbrotImage, transform: Matrix) {
        let iterations = Int(bridgeBuffer.iterations)
        let lenght = image.size.width
        
        DispatchQueue.concurrentPerform(iterations: image.size.height) { row in
            for column in 0 ..< lenght {
                let my = transform.heigh[row]
                let mx = transform.width[column]
                var real: FloatType = 0.0
                var img: FloatType = 0.0
                var i: UInt32 = 0
                
                while i < iterations {
                    let r2 = real * real
                    let i2 = img * img
                    if r2 + i2 > 4.0 { break }
                    img = 2.0 * real * img + my
                    real = r2 - i2 + mx
                    i &+= 1
                }
                
                let pixelOffset = row &* lenght &+ column
                target[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0
            }
        }
    }
}

extension AccelerateRenderer: Renderer {
    var buffer: RendererBuffer {
        get {
            return bridgeBuffer
        }
        set {
            bridgeBuffer = newValue
            render()
        }
    }
    
    func setupRenderer() {
        backgroundColor = .white
        addSubview(mandelbrotImage)
        mandelbrotImage.contentMode = .scaleToFill
        mandelbrotImage.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
