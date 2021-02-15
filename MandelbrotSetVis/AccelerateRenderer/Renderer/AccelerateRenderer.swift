//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit
import Accelerate

final class AccelerateRenderer: UIView {
    private var buffer = RendererBuffer()
    private let mandelbrotImage = UIImageView()
    private var performanceMonitor = PerformanceMonitor()
    
    /// Starts the mandelbrot render process.
    private func render() {
        guard !performanceMonitor.isRunning else { return }
        performanceMonitor.calculationStarted(on: .CPU)
        let blankCgImage = makeCGImage()
        
        DispatchQueue.global(qos: .userInteractive).async {
            let bufferWidth = blankCgImage.width
            let bufferHeight = blankCgImage.height
            let lenght = bufferWidth * bufferHeight
            let cgContext = self.makeContext(from: blankCgImage, width: bufferWidth, height: bufferHeight)
            let buffer = self.makeBuffer(from: cgContext, lenght: lenght)
            let widthBuffer = self.makeWidthBuffer(lenght: bufferWidth)
            let heightBuffer = self.makeHeightBuffer(lenght: bufferHeight)
            self.calculateMandelbrot(buffer: buffer, width: bufferWidth, height: bufferHeight, widthBuffer: widthBuffer, heightBuffer: heightBuffer)
            
            DispatchQueue.main.async {
                self.mandelbrotImage.image = self.makeUIImage(from: cgContext)
                self.performanceMonitor.calculationEnded()
            }
        }
    }
    
    /// Creates a blank cg image from graphic context.
    /// - Returns: Blank cg image.
    private func makeCGImage() -> CGImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Error creating a blank cg image.")
        }
        UIGraphicsEndImageContext()
        return cgImage
    }
    
    /// Makes a CGContext from a given CGImage.
    /// - Parameters:
    ///   - cgImage: Input CGImage
    ///   - width: CGImage's and CGContext's width in pixels.
    ///   - height: CGImage's CGContext's height in pixels.
    /// - Returns: CGContext
    private func makeContext(from cgImage: CGImage, width: Int, height: Int) -> CGContext {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bytesPerRow = bytesPerPixel * width
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create Quartz destination context.")
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
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
    private func makeWidthBuffer(lenght: Int) -> UnsafeMutablePointer<Float32> {
        var widthBuffer = [Float32](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for x in 0 ..< lenght {
                buffer[x] = Float32(x)
            }
            capacity = lenght
        }
        let widthTransformationMultiplier = 2.5 * buffer.aspectRatio.x * buffer.scale
        let widthTranslation = -1.5 * buffer.aspectRatio.x * buffer.scale - buffer.translation.x
        vDSP.divide(widthBuffer, Float32(lenght), result: &widthBuffer)
        vDSP.multiply(widthTransformationMultiplier, widthBuffer, result: &widthBuffer)
        vDSP.add(widthTranslation, widthBuffer, result: &widthBuffer)
        return UnsafeMutablePointer(mutating: widthBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Makes a Float32 buffer of current mandebrot height transformation.
    /// - Parameter lenght: Buffer lenght
    /// - Returns: Float32 buffer of current mandebrot height transformation
    private func makeHeightBuffer(lenght: Int) -> UnsafeMutablePointer<Float32> {
        var heightBuffer = [Float32](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for y in 0 ..< lenght {
                buffer[y] = Float32(y)
            }
            capacity = lenght
        }
        let heightTransformationMultiplier = 2.0 * buffer.aspectRatio.y * buffer.scale
        let heightTranslation = -1.0 * buffer.aspectRatio.y * buffer.scale + buffer.translation.y
        vDSP.divide(heightBuffer, Float32(lenght), result: &heightBuffer)
        vDSP.multiply(heightTransformationMultiplier, heightBuffer, result: &heightBuffer)
        vDSP.add(heightTranslation, heightBuffer, result: &heightBuffer)
        return UnsafeMutablePointer(mutating: heightBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Peforms the main mandebrot calculation cycle.
    /// - Parameters:
    ///   - buffer: Target buffer where the result should be written to.
    ///   - width: Render target's width in pixels.
    ///   - height: Render target's height in pixels.
    ///   - widthBuffer: Float32 buffer of current mandebrot width transformation.
    ///   - heightBuffer: Float32 buffer of current mandebrot heigh transformation.
    private func calculateMandelbrot(buffer: UnsafeMutablePointer<UInt32>,
                                     width: Int,
                                     height: Int,
                                     widthBuffer: UnsafeMutablePointer<Float32>,
                                     heightBuffer: UnsafeMutablePointer<Float32>) {
        
        let mandelbrotIterations = self.buffer.iterations
        
        /// The amount of rows to be processed in a single thread. The default is 1.
        /// Setting it > 1 will make thread creation more efficient on intel, but will result in some weird graphic glitches.
        /// On big.little it will be more efficient at 1.
        let batchSize = 1
        
        DispatchQueue.concurrentPerform(iterations: (height / batchSize) - 1) { (iteration) in
            for batchIndex in 1 ... batchSize {
                let row = iteration &* batchIndex
                //calculateMandelbrotRow(row, width, widthBuffer, heightBuffer, buffer, mandelbrotIterations)
                calculateRow(row: row, rowWidth: width, widthBuffer: widthBuffer, heightBuffer: heightBuffer, targetBuffer: buffer, iterations: mandelbrotIterations)
            }
        }
    }
    
    /// Performs calculation of a single mandolbrot row.
    /// - Parameters:
    ///   - row: Row index.
    ///   - rowWidth: Row width in pixels.
    ///   - widthBuffer: Float32 buffer of current mandebrot width transformation.
    ///   - heightBuffer: Float32 buffer of current mandebrot heigh transformation.
    ///   - targetBuffer: Target buffer where the result should be written to.
    ///   - iterations: Number of mandelbrot iterations.
    @inline(__always)
    private func calculateRow(row: Int,
                              rowWidth: Int,
                              widthBuffer: UnsafeMutablePointer<Float32>,
                              heightBuffer: UnsafeMutablePointer<Float32>,
                              targetBuffer: UnsafeMutablePointer<UInt32>,
                              iterations: Int) {

        for column in 0 ..< rowWidth {
            let my = heightBuffer[row]
            let mx = widthBuffer[column]
            var real: Float32 = 0.0
            var img: Float32 = 0.0
            var i: UInt32 = 0

            while i < iterations {
                let r2 = real * real
                let i2 = img * img
                if r2 + i2 > 4.0 { break }
                img = 2.0 * real * img + my
                real = r2 - i2 + mx
                i &+= 1
            }

            let pixelOffset = row * rowWidth &+ column
            targetBuffer[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0
        }
    }
    
    /// Makes a UIImage from the given CGContext.
    /// - Parameter context: CGContext
    /// - Returns: UIImage from the given CGContext
    private func makeUIImage(from context: CGContext) -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        let scale = UIScreen.main.scale
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
}

extension AccelerateRenderer: Renderer {
    func update() {
        render()
    }
    
    var bridgeBuffer: RendererBuffer {
        get {
            return buffer
        }
        set {
            buffer = newValue
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
