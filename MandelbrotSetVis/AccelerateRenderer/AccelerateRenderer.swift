//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit

final class AccelerateRenderer: UIView {
    var buffer = RendererBuffer()
    
    private let bitmap = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let bytesPerPixel = 4
    private let bitsPerComponent = 8
    private var pallete: UIImage!
    private let mandelbrotImage = UIImageView()
    private var once = true
    
    private func render() {
        guard once else { return }
        once = false
        var monitor = PerformanceMonitor()
        monitor.calculationStarted()
        
        UIGraphicsBeginImageContextWithOptions(frame.size, true, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Invalid bitmap.")
        }
        UIGraphicsEndImageContext()
        mandelbrotImage.image = image
        
        let iterations = buffer.iterations
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = bytesPerPixel * width
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmap) else {
            fatalError("Failed to create Quartz destination context.")
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let buffer = context.data else {
            fatalError("Failed to create bitmap pointer.")
        }
        
        let pixelBuffer = buffer.bindMemory(to: UInt32.self, capacity: width * height)
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let offset = y * width + x
                let pixelShift = UInt32(processPixel(iterations: iterations,
                                                    x: Float32(x) / Float32(width) * 2 - 1,
                                                    y: Float32(y) / Float32(height) * 2 - 1))
                pixelBuffer[offset] = (pixelShift << 24) | (pixelShift << 16) | (pixelShift << 8) | (255 << 0)
            }
        }
        
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        
        let outputImage = UIImage(cgImage: outputCGImage, scale: UIScreen.main.scale, orientation: .up)
        mandelbrotImage.image = outputImage
        
        monitor.calculationEnded()
    }
    
    private func processPixel(iterations: Int, x: Float32, y: Float32) -> Float32 {
        var real: Float32 = 0.0
        var img: Float32 = 0.0
        var i = 0
        while i < iterations && real * real + img * img < 4.0 {
            let temp = (real * real) - (img * img) + x
            img = 2.0 * (real * img) + y
            real = temp
            i += 1
        }
        return (i == iterations ? 0.0 : Float32(i))
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
        guard let palleteFile = Bundle.main.path(forResource: "pallete", ofType: "png"),
              let pallete = UIImage(contentsOfFile: palleteFile) else {
            fatalError("Failed to load color pallete from image.")
        }
        self.pallete = pallete
        addSubview(mandelbrotImage)
        mandelbrotImage.contentMode = .scaleToFill
        mandelbrotImage.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
