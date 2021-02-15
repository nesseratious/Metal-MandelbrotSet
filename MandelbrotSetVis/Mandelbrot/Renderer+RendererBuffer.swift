//
//  RendererProtocol.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

/// Interface for exchanging bridge renderer buffer between a view controller and a entity responsible for rendering.
protocol Renderer: UIView {
    var bridgeBuffer: RendererBuffer { get set }
    func setupRenderer()
}

/// Bridge buffer used for exchanging uniform data between Swift and C/Metal.
/// RendererBuffer struct has the same memory layout as C's MetalBuffer struct.
/// Can be casted as SwiftToMetalConvertible protocol using memcopy or reinterpret cast.
struct RendererBuffer: SwiftToMetalConvertible {
    var scale: Float32 = 1.0
    var iterations: Float32 = 256
    var translation: (x: Float32, y: Float32) = (0.0, 0.0)
    var aspectRatio: (x: Float32, y: Float32) = (1.0, 1.0)
}

protocol SwiftToMetalConvertible { }
