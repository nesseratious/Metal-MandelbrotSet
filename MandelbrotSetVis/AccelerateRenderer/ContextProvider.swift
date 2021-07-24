//
//  ContextProvider.swift
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
    
    unowned var image: MandelbrotImage
    
    init(of image: MandelbrotImage) {
        self.image = image
    }
    
    func makeBuffer() -> UnsafeMutablePointer<UInt32> {
        guard let dataBuffer = context.data else {
            fatalError("Failed to create bitmap pointer.")
        }
        return dataBuffer.bindMemory(to: UInt32.self, capacity: bufferLenght)
    }
    
    /// Total count of pixels in the image.
    lazy var bufferLenght: Int = {
        return image.size.x &* image.size.y
    }()
    
    /// `CGContext` from a given MandelbrotImage.
    lazy var context: CGContext = {
        let bytesPerRow = ContextProvider.bytesPerPixel &* image.size.x
        guard let context = CGContext(data: nil,
                                      width: image.size.x,
                                      height: image.size.y,
                                      bitsPerComponent: ContextProvider.bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: ContextProvider.colorSpace,
                                      bitmapInfo: ContextProvider.bitmapInfo) else {
            fatalError("Failed to create Quartz destination context.")
        }
        let size = CGSize(width: image.size.x, height: image.size.y)
        let frame = CGRect(origin: .zero, size: size)
        context.draw(image.targetCgImage, in: frame)
        return context
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
