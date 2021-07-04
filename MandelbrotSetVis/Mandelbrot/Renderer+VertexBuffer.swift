//
//  Renderer+VertexBuffer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

/// Interface for exchanging renderer buffer between a view controller and a conforming entity responsible for rendering.
protocol Renderer: UIView {
    var vertexBuffer: VertexBuffer { get set }
    func setupRenderer()
}

/// Can be switched between 16, 32 or 64 bit with described limitation :
/// GPU (Metal) doesn't support 64 and 80 bit float
/// Accelerate VDSP doesn't support 80 bit float
/// Mac on intel doesn't support 16 bit float
/// Mac on M1 doesn't support 80 bit float
typealias FloatType = Float32

//TODO: Add 16 and 80 bit float support
//TODO: Add custom lenght float support

/// Bridge used for exchanging data between Swift and Metal.
/// Has the same memory layout as Metal's VertexBuffer struct.
struct VertexBuffer: SwiftToMetalConvertible, Sendable {
    var scale: FloatType = 1
    var iterations: FloatType = 256
    var translation: SIMD2<FloatType> = SIMD2(0, 0)
    var aspectRatio: SIMD2<FloatType> = SIMD2(1, 1)
}

protocol SwiftToMetalConvertible { }
