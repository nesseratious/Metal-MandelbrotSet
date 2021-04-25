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
        var image = MandelbrotImage(for: self)
        var contextProvider = ContextProvider(image: image)
        
        let buffer = makeBuffer(from: contextProvider.context, lenght: image.size)
        
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            calculateMandelbrot(in: buffer, width: image.cgImage.width, height: image.cgImage.height, completion: {
                DispatchQueue.main.async {
                    mandelbrotImage.image = makeUIImage(from: contextProvider.context)
                    performanceMonitor.calculationEnded()
                }
            })
        }
    }
    
    /// Makes a UIImage from the given CGContext.
    /// - Parameter context: CGContext
    /// - Returns: UIImage from the given CGContext
    func makeUIImage(from context: CGContext) -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        let scale = UIScreen.main.scale
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
    
    /// Performs a full mandelbrot calculation cycle (for one frame).
    /// - Parameters:
    ///   - buffer: Target UInt32 buffer where the result should be written to.
    ///   - width: Render target's width.
    ///   - height: Render target's height.
    ///   - completion: Fires when mandelbrot calculation cycle has ended.
    private func calculateMandelbrot(in buffer: UnsafeMutablePointer<UInt32>,
                                     width: Int,
                                     height: Int,
                                     completion: @escaping () -> Void) {
        
        let dispatchGroup = DispatchGroup()
        // widthBuffer heightBuffer are independent, so they can be calculated concurrently.
        
        /// Buffer of current mandebrot per pixel width transformation.
        var widthBuffer: UnsafeMutablePointer<FloatType>!
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            widthBuffer = makeWidthBuffer(lenght: width)
            dispatchGroup.leave()
        }
        
        /// Buffer of current mandebrot per pixel heigh transformation.
        var heightBuffer: UnsafeMutablePointer<FloatType>!
        dispatchGroup.enter()
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            heightBuffer = makeHeightBuffer(lenght: height)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInteractive)) { [self] in
            calculateMandelbrot(buffer: buffer, width: width, height: height, widthBuffer: widthBuffer, heightBuffer: heightBuffer)
            completion()
        }
    }
    
    /// Peforms a mandebrot calculation cycle (for one frame).
    /// - Parameters:
    ///   - buffer: Target UInt32 buffer where the result should be written to.
    ///   - width: Render target's width in pixels.
    ///   - height: Render target's height in pixels.
    ///   - widthBuffer: Float32 buffer of current mandebrot width transformation.
    ///   - heightBuffer: Float32 buffer of current mandebrot heigh transformation.
    private func calculateMandelbrot(buffer: UnsafeMutablePointer<UInt32>,
                                     width: Int,
                                     height: Int,
                                     widthBuffer: UnsafeMutablePointer<FloatType>,
                                     heightBuffer: UnsafeMutablePointer<FloatType>) {
        
        let mandelbrotIterations = Int(bridgeBuffer.iterations)
        
        DispatchQueue.concurrentPerform(iterations: height) { row in
            calculateRow(row, width: width, widthBuffer: widthBuffer, heightBuffer: heightBuffer, targetBuffer: buffer, iterations: mandelbrotIterations)
        }
    }
    
    /// Performs calculation of a single mandolbrot row.
    /// - Parameters:
    ///   - row: Row index (Y position from top).
    ///   - rowWidth: Row width in pixels.
    ///   - widthBuffer: Float32 buffer of current mandebrot width transformation.
    ///   - heightBuffer: Float32 buffer of current mandebrot heigh transformation.
    ///   - targetBuffer: Target buffer where the result should be written to.
    ///   - iterations: Number of mandelbrot iterations.
    @inline(__always)
    private func calculateRow(_ row: Int,
                              width: Int,
                              widthBuffer: UnsafeMutablePointer<FloatType>,
                              heightBuffer: UnsafeMutablePointer<FloatType>,
                              targetBuffer: UnsafeMutablePointer<UInt32>,
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
    
    /// Makes a CGContext from a given CGImage.
    /// - Parameters:
    ///   - cgImage: Input CGImage
    ///   - width: CGImage's CGContext's width in pixels.
    ///   - height: CGImage's CGContext's height in pixels.
    /// - Returns: CGContext
    private func makeContext(from image: inout MandelbrotImage) -> CGContext {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bytesPerRow = bytesPerPixel * image.cgImage.width
        guard let context = CGContext(data: nil, width: image.cgImage.width, height: image.cgImage.height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create Quartz destination context.")
        }
        context.draw(image.cgImage, in: CGRect(x: 0, y: 0, width: image.cgImage.width, height: image.cgImage.height))
        return context
    }
    
    /// Makes a word buffer from a given CGContext.
    /// - Parameters:
    ///   - context: CGContext
    ///   - lenght: CGContext's lenght (widht x height).
    /// - Returns: Pointer to word buffer.
    private func makeBuffer(from context: CGContext, lenght: Int) -> UnsafeMutablePointer<UInt32> {
        guard let dataBuffer = context.data else {
            fatalError("Failed to create bitmap pointer.")
        }
        return dataBuffer.bindMemory(to: UInt32.self, capacity: lenght)
    }
    
    /// Makes a Float32 buffer of current mandebrot width transformation.
    /// - Parameter lenght: Buffer lenght
    /// - Returns: Float32 buffer of current mandebrot width transformation
    private func makeWidthBuffer(lenght: Int) -> UnsafeMutablePointer<FloatType> {
        var widthBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for x in 0 ..< lenght {
                buffer[x] = FloatType(x)
            }
            capacity = lenght
        }
        let widthTransformationMultiplier = 2.5 * bridgeBuffer.aspectRatio.x * bridgeBuffer.scale
        let widthTranslation = -1.5 * bridgeBuffer.aspectRatio.x * bridgeBuffer.scale - bridgeBuffer.translation.x
        vDSP.divide(widthBuffer, FloatType(lenght), result: &widthBuffer)
        vDSP.multiply(widthTransformationMultiplier, widthBuffer, result: &widthBuffer)
        vDSP.add(widthTranslation, widthBuffer, result: &widthBuffer)
        return UnsafeMutablePointer(mutating: widthBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Makes a Float32 buffer of current mandebrot height transformation.
    /// - Parameter lenght: Buffer lenght
    /// - Returns: Float32 buffer of current mandebrot height transformation
    private func makeHeightBuffer(lenght: Int) -> UnsafeMutablePointer<FloatType> {
        var heightBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for y in 0 ..< lenght {
                buffer[y] = FloatType(y)
            }
            capacity = lenght
        }
        let heightTransformationMultiplier = 2.0 * bridgeBuffer.aspectRatio.y * bridgeBuffer.scale
        let heightTranslation = -1.0 * bridgeBuffer.aspectRatio.y * bridgeBuffer.scale + bridgeBuffer.translation.y
        vDSP.divide(heightBuffer, FloatType(lenght), result: &heightBuffer)
        vDSP.multiply(heightTransformationMultiplier, heightBuffer, result: &heightBuffer)
        vDSP.add(heightTranslation, heightBuffer, result: &heightBuffer)
        return UnsafeMutablePointer(mutating: heightBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
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
