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
        let fraction = 4
        let workingWidth = Int(frame.width)/fraction
        let workingHeight = Int(frame.height)/fraction
        let iterations = buffer.iterations
        
        for x in 0...workingWidth {
            for y in 0...workingHeight {
                let pixelShift = CGFloat(processPixel(iterations: iterations,
                                                      x: Float32(x)/Float32(workingWidth)*2-1,
                                                      y: Float32(y)/Float32(workingHeight)*2-1
                                        ))
                let rect = CGRect(x: x*fraction, y: y*fraction, width: 1, height: 1)
                let path = UIBezierPath(rect: rect)
                UIColor(red: pixelShift, green: pixelShift, blue: pixelShift, alpha: 1.0).set()
                path.lineWidth = CGFloat(fraction)
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
        backgroundColor = .white
    }
}
