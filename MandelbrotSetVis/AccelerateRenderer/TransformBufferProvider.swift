//
//  TransformBufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Accelerate

struct TransformBufferProvider {
    var image: MandelbrotImage
    var bridgeBuffer: RendererBuffer
    
    init(with contextProvider: ContextProvider, bridgeBuffer: RendererBuffer) {
        self.image = contextProvider.image
        self.bridgeBuffer = bridgeBuffer
    }
    
    /// Makes a buffer of current mandebrot width transformation.
    /// - Returns: Buffer of current mandebrot width transformation
    mutating func makeWidthBuffer() -> UnsafeMutablePointer<FloatType> {
        let lenght = image.targetCgImage.width
        var widthBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for x in 0 ..< lenght {
                buffer[x] = FloatType(x)
            }
            capacity = lenght
        }
        let widthTransformationMultiplier = 2.5 * bridgeBuffer.aspectRatio.x * bridgeBuffer.scale
        let widthTranslation = -1.5 * bridgeBuffer.aspectRatio.x * bridgeBuffer.scale - bridgeBuffer.translation.x
        
        //TODO: Add fallback for 80 bit float support
        vDSP.divide(widthBuffer, FloatType(lenght), result: &widthBuffer)
        vDSP.multiply(widthTransformationMultiplier, widthBuffer, result: &widthBuffer)
        vDSP.add(widthTranslation, widthBuffer, result: &widthBuffer)
        return UnsafeMutablePointer(mutating: widthBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Makes a buffer of current mandebrot height transformation.
    /// - Returns: Buffer of current mandebrot height transformation
    mutating func makeHeightBuffer() -> UnsafeMutablePointer<FloatType> {
        let lenght = image.targetCgImage.height
        var heightBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { (buffer, capacity) in
            for y in 0 ..< lenght {
                buffer[y] = FloatType(y)
            }
            capacity = lenght
        }
        let heightTransformationMultiplier = 2.0 * bridgeBuffer.aspectRatio.y * bridgeBuffer.scale
        let heightTranslation = -1.0 * bridgeBuffer.aspectRatio.y * bridgeBuffer.scale + bridgeBuffer.translation.y
        
        //TODO: Add fallback for 80 bit float support
        vDSP.divide(heightBuffer, FloatType(lenght), result: &heightBuffer)
        vDSP.multiply(heightTransformationMultiplier, heightBuffer, result: &heightBuffer)
        vDSP.add(heightTranslation, heightBuffer, result: &heightBuffer)
        return UnsafeMutablePointer(mutating: heightBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
}
