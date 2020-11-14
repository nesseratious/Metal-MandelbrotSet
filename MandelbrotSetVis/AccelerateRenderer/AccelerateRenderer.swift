//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit
import Accelerate

final class AccelerateRenderer: UIView {
    var buffer = RendererBuffer()
    
    override func draw(_ rect: CGRect) {
        let width = frame.width
        let height = frame.height
        
        for x in -100...100 {
            for y in -100...100 {
                let pixel = CGFloat(processPixel(iterations: 256, x: Float32(x)/100, y: Float32(y)/100))
                let x = (CGFloat(x) / 200 * width) + (width / 2)
                let y = CGFloat(y) / 200 * height + (height / 2)
                let rect = CGRect(x: x, y: y, width: 2, height: 2)
                let path = UIBezierPath(rect: rect)
                path.close()
                UIColor(red: pixel, green: pixel, blue: pixel, alpha: pixel).set()
                path.lineWidth = 2.0
                path.stroke()
            }
        }
    }
    
    private func render() {
        setNeedsDisplay()
    }
    
    private func processPixel(iterations: Int, x: Float32, y: Float32) -> Float32 {
        var real: Float32 = 0.0;
        var img: Float32 = 0.0;
        var i = 0;
        while i < iterations && real * real + img * img < 10.0 {
            let temp = (real * real) - (img * img) + x;
            img = 2.0 * (real * img) + y;
            real = temp;
            i += 1
        }
        return (i == iterations ? 0.0 : Float32(i)) / 256
    }
}

extension AccelerateRenderer: Renderer {
    var view: UIView {
        return self
    }
    
    var bridgeBuffer: RendererBuffer {
        get {
            return buffer
        }
        set {
            buffer = newValue
            render()
        }
    }
    
    func setupRenderer() {
        
    }
}
