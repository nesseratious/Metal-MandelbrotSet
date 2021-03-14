//
//  BufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

/// Provides a Metal GPU buffer.
struct MetalBufferProvider {
    private let buffer: MTLBuffer
    
    init(device: MTLDevice) {
        let size = MemoryLayout<Float32>.size * 8
        guard let buffer = device.makeBuffer(length: size) else {
            fatalError("Failed making buffer")
        }
        self.buffer = buffer
    }
    
    /// Creates the Metal GPU buffer and copies Swift uniform struct to it.
    /// - Parameter uniform: Swift uniform struct (bridge buffer used for exchanging uniform data between Swift and C/Metal).
    /// - Returns: Metal GPU buffer
    func make(with uniform: SwiftToMetalConvertible) -> MTLBuffer {
        let _ = withUnsafePointer(to: uniform) {
            let size = MemoryLayout<Float32>.size * 8
            let contents = buffer.contents()
            memcpy(contents, $0, size)
        }
        return buffer
    }
}
