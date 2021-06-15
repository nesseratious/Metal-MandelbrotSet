//
//  RendererProtocol.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

/// Interface for exchanging bridge renderer buffer between a view controller and a conforming entity responsible for rendering.
protocol Renderer: UIView {
    var buffer: RendererBuffer { get set }
    func setupRenderer()
}

/// Can be switched between 16, 32 or 64 bit
/// GPU (Metal) doesn't support 64 and 80 bit float
/// Accelerate VDSP doesn't support 80 bit float
/// Mac on intel doesn't support 16 bit float
/// Mac on M1 doesn't support 80 bit float
typealias FloatType = Float32

//TODO: Add 16 and 80 bit float support

/// Bridge buffer used for exchanging uniform data between Swift and C/Metal.
/// RendererBuffer struct has the same memory layout as C's MetalBuffer struct.
/// Can be casted as SwiftToMetalConvertible protocol using memcopy or reinterpret cast.
struct RendererBuffer: SwiftToMetalConvertible {
    var scale: FloatType = 1.0
    var iterations: FloatType = 256
    var translation: (x: FloatType, y: FloatType) = (0.0, 0.0)
    var aspectRatio: (x: FloatType, y: FloatType) = (1.0, 1.0)
}

protocol SwiftToMetalConvertible { }
