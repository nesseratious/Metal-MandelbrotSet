//
//  CGContextProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Foundation
import UIKit

final class ContextProvider {
    private static let bytesPerPixel = 4
    private static let bitsPerComponent = 8
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()
    private static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    var image: MandelbrotImage
    
    init(image: MandelbrotImage) {
        self.image = image
    }
    
    /// CGContext from a given MandelbrotImage.
    lazy var context: CGContext = {
        let bytesPerRow = ContextProvider.bytesPerPixel &* image.targetCgImage.width
        guard let context = CGContext(data: nil,
                                      width: image.size.width,
                                      height: image.size.height,
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
    
    /// Makes an UIImage from the current CGContext.
    /// - Returns: UIImage from the current CGContext
    func generateUIImage() -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from the current context.")
        }
        let scale = UIScreen.main.scale
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
}
