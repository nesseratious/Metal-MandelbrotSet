//
//  CGContextProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Foundation

struct ContextProvider {
    private static let bytesPerPixel = 4
    private static let bitsPerComponent = 8
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()
    private static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
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
        let bytesPerRow = ContextProvider.bytesPerPixel &* image.targetCgImage.width
        
        guard let context = CGContext(data: nil,
                                      width: image.targetCgImage.width,
                                      height: image.targetCgImage.height,
                                      bitsPerComponent: ContextProvider.bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: ContextProvider.colorSpace,
                                      bitmapInfo: ContextProvider.bitmapInfo) else {
            fatalError("Failed to create Quartz destination context.")
        }
        let frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context.draw(image.targetCgImage, in: frame)
        return context
    }()
    
    /// Total count of pixels in the image.
    lazy var bufferLenght: Int = {
        return image.size.width &* image.size.height
    }()
}
