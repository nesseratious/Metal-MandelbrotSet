//
//  RendererProtocol.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

protocol Renderer: UIView {
    var bridgeBuffer: RendererBuffer { get set }
    func setupRenderer()
    func update()
}

struct RendererBuffer {
    var scale: Float32 = 1.0
    var translation: (x: Float32, y: Float32) = (0.0, 0.0)
    var aspectRatio: (x: Float32, y: Float32) = (1.0, 1.0)
    var iterations: Int = 256
}
