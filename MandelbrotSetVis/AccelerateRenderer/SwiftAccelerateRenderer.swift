//
//  SwiftAccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit
import Accelerate

final class SwiftAccelerateRenderer: UIView {
    private var buffer = RendererBuffer()
    private let mandelbrotImage = UIImageView()
    private var monitor = PerformanceMonitor()
    
    private func render() {
        guard !monitor.isRunning else { return }
        monitor.calculationStarted(on: .CPU)
        let cgImage = makeCGImage()
        
        DispatchQueue.global(qos: .userInteractive).async {
            let bufferWidth = cgImage.width
            let bufferHeight = cgImage.height
            let lenght = bufferWidth * bufferHeight
            let cgContext = self.makeContext(from: cgImage, width: bufferWidth, height: bufferHeight)
            let buffer = self.makeBuffer(from: cgContext, lenght: lenght)
            let widthBuffer = self.makeWidthBuffer(lenght: bufferWidth)
            let heightBuffer = self.makeHeightBuffer(lenght: bufferHeight)
            self.calculateMandelbrot(buffer: buffer, width: bufferWidth, height: bufferHeight, widthBuffer: widthBuffer, heightBuffer: heightBuffer)
            
            DispatchQueue.main.async {
                self.mandelbrotImage.image = self.makeUIImage(from: cgContext)
                self.monitor.calculationEnded()
            }
        }
    }
    
    private func makeCGImage() -> CGImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Invalid bitmap.")
        }
        UIGraphicsEndImageContext()
        return cgImage
    }
    
    private func makeContext(from cgImage: CGImage, width: Int, height: Int) -> CGContext {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmap = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bytesPerRow = bytesPerPixel * width
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmap) else {
            fatalError("Failed to create Quartz destination context.")
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }
    
    private func makeBuffer(from context: CGContext, lenght: Int) -> UnsafeMutablePointer<UInt32> {
        guard let dataBuffer = context.data else {
            fatalError("Failed to create bitmap pointer.")
        }
        return dataBuffer.bindMemory(to: UInt32.self, capacity: lenght)
    }
    
    private func makeWidthBuffer(lenght: Int) -> UnsafeBufferPointer<Float32> {
        var widthBuffer = [Float32](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for x in 0 ..< lenght {
                buffer[x] = Float32(x)
            }
            capacity = lenght
        }
        vDSP.divide(widthBuffer, Float32(lenght), result: &widthBuffer)
        vDSP.multiply(2.5 * buffer.aspectRatio.x * buffer.scale, widthBuffer, result: &widthBuffer)
        vDSP.add(-1.5 * buffer.aspectRatio.x * buffer.scale - buffer.translation.x, widthBuffer, result: &widthBuffer)
        let ptr = widthBuffer.withUnsafeBufferPointer { $0 }
        return ptr
    }
    
    private func makeHeightBuffer(lenght: Int) -> UnsafeBufferPointer<Float32> {
        var heightBuffer = [Float32](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for y in 0 ..< lenght {
                buffer[y] = Float32(y)
            }
            capacity = lenght
        }
        vDSP.divide(heightBuffer, Float32(lenght), result: &heightBuffer)
        vDSP.multiply(2.0 * buffer.aspectRatio.y * buffer.scale, heightBuffer, result: &heightBuffer)
        vDSP.add(-1.0 * buffer.aspectRatio.y * buffer.scale + buffer.translation.y, heightBuffer, result: &heightBuffer)
        let ptr = heightBuffer.withUnsafeBufferPointer { $0 }
        return ptr
    }
    
    private func calculateMandelbrot(buffer: UnsafeMutablePointer<UInt32>,
                                     width: Int,
                                     height: Int,
                                     widthBuffer: UnsafeBufferPointer<Float32>,
                                     heightBuffer: UnsafeBufferPointer<Float32>) {
        
        let mandelbrotIterations = self.buffer.iterations
        let batchSize = 16
        
        DispatchQueue.concurrentPerform(iterations: (height / batchSize) - 1) { (iteration) in
            for batchIndex in 1 ... batchSize {
                let row = iteration &* batchIndex
                
                for column in 0 ..< width {
                    let my = heightBuffer[row]
                    let mx = widthBuffer[column]
                    var real: Float32 = 0.0
                    var img: Float32 = 0.0
                    var i = 0
                    
                    while i < mandelbrotIterations {
                        let r2 = real * real
                        let i2 = img * img
                        if r2 + i2 > 4.0 { break }
                        img = 2.0 * real * img + my
                        real = r2 - i2 + mx
                        i &+= 1
                    }
                    
                    let offset = row * width &+ column
                    let pixelShift = UInt32(i)
                    buffer[offset] = pixelShift << 24 | pixelShift << 16 | pixelShift << 8 | 255 << 0
                }
            }
        }
    }
    
    func makeUIImage(from context: CGContext) -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        let scale = UIScreen.main.scale
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
}

extension SwiftAccelerateRenderer: Renderer {
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
