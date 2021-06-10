//
//  TransformBufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Accelerate
import simd

final class TransformBufferProvider {
    unowned let image: MandelbrotImage
    var buffer: RendererBuffer
    
    init(with contextProvider: ContextProvider, bridgeBuffer: RendererBuffer) {
        self.image = contextProvider.image
        self.buffer = bridgeBuffer
    }
    
    /// Makes a buffer of current mandebrot width transformation.
    /// - Returns: Buffer of current mandebrot width transformation
    func makeWidthBuffer() async -> Buffer {
        let lenght = image.targetCgImage.width
        var widthBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { buffer, capacity in
            for x in 0 ..< lenght {
                buffer[x] = FloatType(x)
            }
            capacity = lenght
        }
        let transformVec = SIMD2<FloatType>(x: 2.5, y: -1.5 - buffer.translation.x) * buffer.aspectRatio.x * buffer.scale

        //TODO: Add fallback for 80 bit float support
        vDSP.divide(widthBuffer, FloatType(lenght), result: &widthBuffer)
        vDSP.multiply(transformVec.x, widthBuffer, result: &widthBuffer)
        vDSP.add(transformVec.y, widthBuffer, result: &widthBuffer)
        return UnsafeMutablePointer(mutating: widthBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Makes a buffer of current mandebrot height transformation.
    /// - Returns: Buffer of current mandebrot height transformation
    func makeHeightBuffer() async -> Buffer {
        let lenght = image.targetCgImage.height
        var heightBuffer = [FloatType](unsafeUninitializedCapacity: lenght) { buffer, capacity in
            for y in 0 ..< lenght {
                buffer[y] = FloatType(y)
            }
            capacity = lenght
        }
        let transformVec = SIMD2<FloatType>(x: 2.0, y: -1.0 + buffer.translation.y) * buffer.aspectRatio.y * buffer.scale

        //TODO: Add fallback for 80 bit float support
        vDSP.divide(heightBuffer, FloatType(lenght), result: &heightBuffer)
        vDSP.multiply(transformVec.x, heightBuffer, result: &heightBuffer)
        vDSP.add(transformVec.y, heightBuffer, result: &heightBuffer)
        return UnsafeMutablePointer(mutating: heightBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
}
