//
//  BufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

struct MetalBufferProvider {
    private let buffer: MTLBuffer
    
    init?(device: MTLDevice) {
        let size = MemoryLayout<Float32>.size * 8
        let options = MTLResourceOptions()
        guard let buffer = device.makeBuffer(length: size, options: options) else { return nil }
        self.buffer = buffer
    }
    
    func makeBuffer(with uniform: SwiftToMetalConvertible) -> MTLBuffer {
        let size = MemoryLayout<Float32>.size * 8
        let contents = buffer.contents()
        memcpy(contents, uniform.getRawData(), size)
        return buffer
    }
}
