//
//  RendererProtocol.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import UIKit

protocol Renderer: class {
    var view: UIView { get }
    var bridgeBuffer: RendererBuffer { get set }
    func setupRenderer()
}
