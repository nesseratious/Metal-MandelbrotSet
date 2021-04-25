//
//  CGContextProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Foundation

struct ContextProvider {
    var image: MandelbrotImage
    
    init(image: MandelbrotImage) {
        self.image = image
    }
    
    /// Makes a CGContext from a given CGImage.
    /// - Parameters:
    ///   - cgImage: Input CGImage
    ///   - width: CGImage's CGContext's width in pixels.
    ///   - height: CGImage's CGContext's height in pixels.
    /// - Returns: CGContext
    lazy var context: CGContext = {
        let bytesPerPixel = 4
        let bitsPerComponent = 8
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bytesPerRow = bytesPerPixel * image.targetCgImage.width
        
        guard let context = CGContext(data: nil, width: image.targetCgImage.width, height: image.targetCgImage.height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            fatalError("Failed to create Quartz destination context.")
        }
        let frame = CGRect(x: 0, y: 0, width: image.targetCgImage.width, height: image.targetCgImage.height)
        context.draw(image.targetCgImage, in: frame)
        return context
    }()
    
    /// Total count of pixels in the image.
    lazy var bufferLenght: Int = {
        return Int(image.size.width) &* Int(image.size.height)
    }()
}
