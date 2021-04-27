//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit
import Accelerate

/// Provides the view with mandelbrot image rendered using power of CPU.
final class AccelerateRenderer: UIView {
    private var bridgeBuffer = RendererBuffer()
    private let mandelbrotImage = UIImageView()
    private var performanceMonitor = PerformanceMonitor()
        
    /// Starts the mandelbrot render process.
    private func render() {
        guard !performanceMonitor.isRunning else { return }
        performanceMonitor.calculationStarted(on: .CPU)
        let image = MandelbrotImage(for: self)
        var contextProvider = ContextProvider(image: image)
        let buffer = makeBuffer(from: contextProvider.context, lenght: contextProvider.bufferLenght)
        
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            calculateMandelbrot(in: buffer, contextProvider: contextProvider, onCompleted: {
                DispatchQueue.main.async {
                    mandelbrotImage.image = contextProvider.generateUIImage()
                    performanceMonitor.calculationEnded()
                }
            })
        }
    }
    
    private func calculateMandelbrot(in buffer: UnsafeMutablePointer<UInt32>,
                                     contextProvider: ContextProvider,
                                     onCompleted: @escaping () -> Void) {
        
        var image = contextProvider.image
        var bufferProvider = TransformBufferProvider(with: contextProvider, bridgeBuffer: bridgeBuffer)
        let dispatchGroup = DispatchGroup()

        /// Buffer of current mandebrot per pixel width transformation.
        var widthBuffer: UnsafeMutablePointer<FloatType>!
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            widthBuffer = bufferProvider.makeWidthBuffer()
            dispatchGroup.leave()
        }
        
        /// Buffer of current mandebrot per pixel heigh transformation.
        var heightBuffer: UnsafeMutablePointer<FloatType>!
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            heightBuffer = bufferProvider.makeHeightBuffer()
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInteractive)) { [self] in
            concurrentCalculate(writeTo: buffer, image: &image, widthBuffer: widthBuffer, heightBuffer: heightBuffer)
            onCompleted()
        }
    }
    
    private func concurrentCalculate(writeTo buffer: UnsafeMutablePointer<UInt32>,
                                     image: inout MandelbrotImage,
                                     widthBuffer: UnsafeMutablePointer<FloatType>,
                                     heightBuffer: UnsafeMutablePointer<FloatType>) {
        
        let mandelbrotIterations = Int(bridgeBuffer.iterations)
        
        DispatchQueue.concurrentPerform(iterations: image.size.height) { row in
            calculateRow(row, width: image.size.width, widthBuffer: widthBuffer, heightBuffer: heightBuffer, writeTo: buffer, iterations: mandelbrotIterations)
        }
    }
    
    @inline(__always)
    private func calculateRow(_ row: Int,
                              width: Int,
                              widthBuffer: UnsafeMutablePointer<FloatType>,
                              heightBuffer: UnsafeMutablePointer<FloatType>,
                              writeTo targetBuffer: UnsafeMutablePointer<UInt32>,
                              iterations: Int) {

        for column in 0 ..< width {
            let my = heightBuffer[row]
            let mx = widthBuffer[column]
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

            let pixelOffset = row &* width &+ column
            targetBuffer[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0
        }
    }
    
    private func makeBuffer(from context: CGContext, lenght: Int) -> UnsafeMutablePointer<UInt32> {
        guard let dataBuffer = context.data else {
            fatalError("Failed to create bitmap pointer.")
        }
        return dataBuffer.bindMemory(to: UInt32.self, capacity: lenght)
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
