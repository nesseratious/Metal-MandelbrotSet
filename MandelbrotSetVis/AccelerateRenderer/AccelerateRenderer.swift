//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit

/// View with mandelbrot image rendered using the power of CPU.
final class AccelerateRenderer: UIView, Renderer {
    private let mandelbrotImage = UIImageView()
    private var performanceMonitor = PerformanceMonitor()
    private lazy var image = MandelbrotImage(for: self)
    private lazy var contextProvider = ContextProvider(of: image)
    
    var vertexBuffer = VertexBuffer() {
        didSet {
            render()
        }
    }
    
    func setupRenderer() {
        backgroundColor = .white
        addSubview(mandelbrotImage)
        mandelbrotImage.contentMode = .scaleToFill
        mandelbrotImage.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
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
        let bufferProvider = TransformBufferProvider(with: contextProvider, bridgeBuffer: vertexBuffer)
        async let widthBuffer = bufferProvider.makeWidthBuffer()
        async let heightBuffer = bufferProvider.makeHeightBuffer()
        let matrix = await Matrix(width: widthBuffer, heigh: heightBuffer)
        calculate(target: buffer, image: contextProvider.image, transform: matrix)
    }
    
    private func calculate(target: UnsafeMutablePointer<UInt32>, image: MandelbrotImage, transform: Matrix) {
        let iterations = Int(vertexBuffer.iterations)
        let lenght = image.size.width
        
        DispatchQueue.concurrentPerform(iterations: image.size.height) { row in
            for column in 0 ..< lenght {
                let transformVec = SIMD2<FloatType>(x: transform.width[column], y: transform.heigh[row])
                var complex = SIMD2<FloatType>(x: 0, y: 0) // x is real, y is img
                var i: UInt32 = 0
                
                while i < iterations {
                    let r3 = complex * complex
                    if r3.sum() > 4.0 { break }
                    complex.y = 2.0 * complex.x * complex.y
                    complex.x = r3.x - r3.y
                    complex += transformVec
                    i &+= 1
                }
                
                let pixelOffset = row &* lenght &+ column
                target[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0
            }
        }
    }
}
