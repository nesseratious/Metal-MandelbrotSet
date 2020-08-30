//
//  RenderBuffer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

struct RendererBuffer {
    var scale: Float32 = 1.0
    var translation: (x: Float32, y: Float32) = (0.0, 0.0)
    var aspectRatio: (x: Float32, y: Float32) = (1.0, 1.0)
    var interations: Float32 = 256.0
}

extension RendererBuffer: SwiftToMetalConvertible {
    var unsafeRawData: [Float32] {
        [scale, interations, translation.x, translation.y, aspectRatio.x, aspectRatio.y]
    }
}
