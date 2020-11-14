//
//  AccelerateRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation
import UIKit

final class AccelerateRenderer: UIView {
    var buffer = RendererBuffer()
    var pallete: UIImage!
    
    override func draw(_ rect: CGRect) {
        var monitor = PerformanceMonitor()
        monitor.calculationStarted()
        
        let fraction = 1
        let workingWidth = Int(frame.width)/fraction
        let workingHeight = Int(frame.height)/fraction
        let iterations = buffer.iterations
        
        for x in 0...workingWidth {
            for y in 0...workingHeight {
                let pixelShift = CGFloat(processPixel(iterations: iterations,
                                                      x: Float32(x) / Float32(workingWidth) * 2 - 1,
                                                      y: Float32(y) / Float32(workingHeight) * 2 - 1
                                        ))
                let rect = CGRect(x: x*fraction, y: y*fraction, width: 1, height: 1)
                let path = UIBezierPath(rect: rect)
                getPixelColor(Int(pixelShift)).set()
                path.lineWidth = CGFloat(fraction)
                path.stroke()
            }
        }
        
        monitor.calculationEnded()
    }
    
    private func render() {
        setNeedsDisplay()
    }
    
    private func processPixel(iterations: Int, x: Float32, y: Float32) -> Float32 {
        var real: Float32 = 0.0
        var img: Float32 = 0.0
        var i = 0
        while i < iterations && real * real + img * img < 4.0 {
            let temp = (real * real) - (img * img) + x
            img = 2.0 * (real * img) + y
            real = temp
            i += 1
        }
        return (i == iterations ? 0.0 : Float32(i)) / 50
    }
    
    private func getPixelColor(_ pos: Int) -> UIColor {
        let pixelData = pallete.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo = ((Int(pallete.size.width) * pos) + 1) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension AccelerateRenderer: Renderer {
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
        guard let palleteFile = Bundle.main.path(forResource: "pallete", ofType: "png"),
        let pallete = UIImage(contentsOfFile: palleteFile) else {
            fatalError("Failed to load color pallete from image.")
        }
        self.pallete = pallete
    }
}
