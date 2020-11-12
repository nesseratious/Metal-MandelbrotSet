//
//  RendererBuffer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/12/20.
//

struct RendererBuffer {
    var scale: Float32 = 1.0
    var translation: (x: Float32, y: Float32) = (0.0, 0.0)
    var aspectRatio: (x: Float32, y: Float32) = (1.0, 1.0)
    var interations: Float32 = 256.0
}
