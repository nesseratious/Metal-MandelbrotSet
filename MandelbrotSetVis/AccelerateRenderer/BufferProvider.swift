//
//  BufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/25/21.
//

import Foundation
import Accelerate

struct BufferProvider {
    var image: MandelbrotImage
    var contextProvider: ContextProvider
    var bridgeBuffer: RendererBuffer
    
    init(with contextProvider: ContextProvider, bridgeBuffer: RendererBuffer) {
        self.image = contextProvider.image
        self.contextProvider = contextProvider
        self.bridgeBuffer = bridgeBuffer
    }
    
    /// Makes a word buffer from a given CGContext.
    /// - Parameters:
    ///   - context: CGContext
    ///   - lenght: CGContext's lenght (widht x height).
    /// - Returns: Pointer to word buffer.
    mutating func makeBuffer() -> UnsafeMutablePointer<UInt32> {
        guard let dataBuffer = contextProvider.context.data else {
            fatalError("Failed to create a bitmap pointer.")
        }
        return dataBuffer.bindMemory(to: UInt32.self, capacity: contextProvider.bufferLenght)
    }
    
    /// Makes a Float32 buffer of current mandebrot width transformation.
    /// - Parameter lenght: Buffer lenght
    /// - Returns: Float32 buffer of current mandebrot width transformation
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
        vDSP.divide(widthBuffer, FloatType(lenght), result: &widthBuffer)
        vDSP.multiply(widthTransformationMultiplier, widthBuffer, result: &widthBuffer)
        vDSP.add(widthTranslation, widthBuffer, result: &widthBuffer)
        return UnsafeMutablePointer(mutating: widthBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
    
    /// Makes a Float32 buffer of current mandebrot height transformation.
    /// - Parameter lenght: Buffer lenght
    /// - Returns: Float32 buffer of current mandebrot height transformation
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
        vDSP.divide(heightBuffer, FloatType(lenght), result: &heightBuffer)
        vDSP.multiply(heightTransformationMultiplier, heightBuffer, result: &heightBuffer)
        vDSP.add(heightTranslation, heightBuffer, result: &heightBuffer)
        return UnsafeMutablePointer(mutating: heightBuffer.withUnsafeBufferPointer { $0 }.baseAddress!)
    }
}
