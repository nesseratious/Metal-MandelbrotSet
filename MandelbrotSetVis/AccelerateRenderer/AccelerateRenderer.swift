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
        let width = Int(frame.width)
        let height = Int(frame.height)
        
        for x in 0..<100 {
            for y in 0..<100 {
                let pixel = CGFloat(processPixel(iterations: 64, x: Float32(x)/100, y: Float32(y)/100))/256
                print(pixel)
                let aPath = UIBezierPath()
                aPath.move(to: CGPoint(x: x, y: y))
                aPath.addLine(to: CGPoint(x: x+1, y: y+1))
                aPath.close()
                UIColor(red: pixel, green: pixel, blue: pixel, alpha: pixel).set()
                aPath.lineWidth = 5.0
                aPath.stroke()
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
        return i == iterations ? 0.0 : Float32(i);
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
