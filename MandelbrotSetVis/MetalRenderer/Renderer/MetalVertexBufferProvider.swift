//
//  Shapes.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

struct MetalVertexBufferProvider {
    private let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func make() -> MTLBuffer? {
        var vertices = [Vertex(x: -1.0, y: -1.0, z: 0),
                        Vertex(x: -1.0, y: 1.0, z: 0),
                        Vertex(x: 1.0, y: -1.0, z: 0),
                        Vertex(x: -1.0, y: 1.0, z: 0),
                        Vertex(x: 1.0, y: 1.0, z: 0),
                        Vertex(x: 1.0, y: -1.0, z: 0)]
        let lenght = vertices.count * MemoryLayout<Vertex>.size
        let options = MTLResourceOptions()
        return device.makeBuffer(bytes: &vertices, length: lenght, options: options)
    }
    
    struct Vertex {
        let x: Float
        let y: Float
        let z: Float
    }
}