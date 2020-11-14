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
}
