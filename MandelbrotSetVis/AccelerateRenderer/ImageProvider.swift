//
//  ImageProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/22/21.
//

import UIKit

struct ImageProvider {
    private unowned let view: UIView
    
    init(for view: UIView) {
        self.view = view
    }
    
    /// a blank cg image from graphic context.
    lazy var cgImage: CGImage = {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Error creating a blank cg image.")
        }
        UIGraphicsEndImageContext()
        return cgImage
    }()
    
    /// Makes a UIImage from the given CGContext.
    /// - Parameter context: CGContext
    /// - Returns: UIImage from the given CGContext
    func makeUIImage(from context: CGContext) -> UIImage {
        guard let outputCGImage = context.makeImage() else {
            fatalError("Failed to create cgimage from context.")
        }
        let scale = UIScreen.main.scale
        return UIImage(cgImage: outputCGImage, scale: scale, orientation: .up)
    }
}
