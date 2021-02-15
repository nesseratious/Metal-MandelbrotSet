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
    
    init(device: MTLDevice) {
        let size = MemoryLayout<Float32>.size * 8
        let options = MTLResourceOptions()
        guard let buffer = device.makeBuffer(length: size, options: options) else {
            fatalError("Failed making buffer")
        }
        self.buffer = buffer
    }
    
    func make(with uniform: SwiftToMetalConvertible) -> MTLBuffer {
        let size = MemoryLayout<Float32>.size * 8
        let contents = buffer.contents()
        let ptr = withUnsafePointer(to: uniform, { $0 })
        memcpy(contents, ptr, size)
        return buffer
    }
}
