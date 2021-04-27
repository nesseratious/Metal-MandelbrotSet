//
//  TransformBufferProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

struct MetalBufferProvider {
    private unowned let device: MTLDevice
    
    init(with device: MTLDevice) {
        self.device = device
    }
    
    /// Creates the Metal GPU buffer and copies Swift uniform struct to it.
    /// - Parameter uniform: Swift uniform struct (bridge buffer used for exchanging uniform data between Swift and C/Metal).
    /// - Returns: Metal GPU buffer
    func make(with uniform: SwiftToMetalConvertible) -> MTLBuffer {
        let size = MemoryLayout<FloatType>.size * 8
        guard let buffer = device.makeBuffer(length: size) else {
            fatalError("Failed making buffer")
        }
        let _ = withUnsafePointer(to: uniform) {
            let contents = buffer.contents()
            memcpy(contents, $0, size)
        }
        return buffer
    }
}
