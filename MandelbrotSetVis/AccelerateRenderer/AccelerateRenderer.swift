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
    var buffer = RendererBuffer()
    private let bitmap = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let bytesPerPixel = 4
    private let bitsPerComponent = 8
    private let mandelbrotImage = UIImageView()
    private let scale = UIScreen.main.scale
//    private var once = true
    
    private func render() {
//        guard once else { return }
//        once = false
        var monitor = PerformanceMonitor()
        monitor.calculationStarted()
        
        let cgImage = makeCGImage()
        let width = cgImage.width
        let height = cgImage.height
        let capacity = width * height
        
        let context = makeContext(cgImage: cgImage, width: width, height: height)
        let buffer = makeBuffer(context: context, lenght: capacity)
        let widthBuffer = makeWidthBuffer(lenght: width)
        let heightBuffer = makeHeightBuffer(lenght: height)
        
        calculateMandelbrot(buffer: buffer, width: width, height: height, widthBuffer: widthBuffer, heightBuffer: heightBuffer)
        mandelbrotImage.image = makeImage(context: context)
        monitor.calculationEnded()
    }
    
    private func makeCGImage() -> CGImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, true, scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Invalid bitmap.")
        }
        UIGraphicsEndImageContext()
        return cgImage
    }
    
    private func makeContext(cgImage: CGImage, width: Int, height: Int) -> CGContext {
        let bytesPerRow = bytesPerPixel * width
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmap) else {
            fatalError("Failed to create Quartz destination context.")
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context
    }
    
    private func makeBuffer(context: CGContext, lenght: Int) -> UnsafeMutablePointer<UInt32> {
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
        vDSP.multiply(2.0, widthBuffer, result: &widthBuffer)
        vDSP.add(-1.0, widthBuffer, result: &widthBuffer)
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
        vDSP.multiply(2.0, heightBuffer, result: &heightBuffer)
        vDSP.add(-1.0, heightBuffer, result: &heightBuffer)
        let ptr = heightBuffer.withUnsafeBufferPointer { $0 }
        return ptr
    }
    
    private func calculateMandelbrot(buffer: UnsafeMutablePointer<UInt32>,
                                     width: Int,
                                     height: Int,
                                     widthBuffer: UnsafeBufferPointer<Float32>,
                                     heightBuffer: UnsafeBufferPointer<Float32>) {
        
        let iterations = self.buffer.iterations
        for y in 0 ..< height {
            for x in 0 ..< width {
                
                let my = heightBuffer[y]
                let mx = widthBuffer[x]
                var real: Float32 = 0.0
                var img: Float32 = 0.0
                var i = 0
                
                while i < iterations {
                    let r2 = real * real
                    let i2 = img * img
                    if r2 + i2 > 4.0 { break }
                    img = 2.0 * real * img + my
                    real = r2 - i2 + mx
                    i &+= 1
                }
                
                let offset = y * width &+ x
                let pixelShift = UInt32(i)
                buffer[offset] = pixelShift << 24 | pixelShift << 16 | pixelShift << 8 | 255 << 0
            }
        }
    }
    
    func makeImage(context: CGContext) -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
}

extension AccelerateRenderer: Renderer {
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
