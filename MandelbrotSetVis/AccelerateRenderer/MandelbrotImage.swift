//
//  ImageProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/22/21.
//

import UIKit

struct MandelbrotImage {
    private unowned let view: UIView
    
    init(for view: UIView) {
        self.view = view
    }
    
    /// Blank cg image with size of the provided owner view.
    lazy var targetCgImage: CGImage = {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
              let cgImage = image.cgImage else {
            fatalError("Error creating a blank cg image.")
        }
        UIGraphicsEndImageContext()
        return cgImage
    }()
    
    /// Total count of pixels in the image.
    lazy var size: CGSize = {
        return CGSize(width: targetCgImage.width, height: targetCgImage.height)
    }()
}
