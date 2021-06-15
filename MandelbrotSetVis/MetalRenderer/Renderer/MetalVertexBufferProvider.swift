//
//  Shapes.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

struct MetalVertexBufferProvider {
    private unowned let device: MTLDevice
    
    init(with device: MTLDevice) {
        self.device = device
    }
    
    /// Creates a Metal vertex buffer.
    /// - Returns: Metal vertex buffer.
    func make() -> MTLBuffer? {
        let vertices: [FloatType] =
            [-1.0, -1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0, -1.0,  0.0,
             -1.0,  1.0,  0.0,
              1.0,  1.0,  0.0,
              1.0, -1.0,  0.0]
        let lenght = vertices.count * MemoryLayout<FloatType>.stride * 3
        return device.makeBuffer(bytes: vertices, length: lenght)
    }
}
