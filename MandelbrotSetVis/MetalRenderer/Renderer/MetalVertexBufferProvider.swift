//
//  Shapes.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

/// Provides a Metal vertex buffer.
struct MetalVertexBufferProvider {
    private let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    /// Created a Metal vertex buffer.
    /// - Returns: Metal vertex buffer.
    func make() -> MTLBuffer? {
        let vertices: [Float] =
            [-1.0, -1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0, -1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0,  1.0,  0.0,
              1.0, -1.0,  0.0]
        let lenght = vertices.count * MemoryLayout<Float>.size * 3
        return device.makeBuffer(bytes: vertices, length: lenght)
    }
}
