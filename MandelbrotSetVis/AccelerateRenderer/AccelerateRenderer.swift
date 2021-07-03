//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

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
        calculate(in: buffer, image: contextProvider.image, transform: matrix)
    }
    
    private func calculate(in buffer: UnsafeMutablePointer<UInt32>, image: MandelbrotImage, transform: Matrix) {
        let iterations = Int(vertexBuffer.iterations)
        let lenght = image.size.x
        
        DispatchQueue.concurrentPerform(iterations: image.size.y) { row in
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
                buffer[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0
            }
        }
    }
}
