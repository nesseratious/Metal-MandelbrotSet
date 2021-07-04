//
//  ImageProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 4/22/21.
//

import UIKit

final class MandelbrotImage {
    private unowned let view: UIView
    
    init(for view: UIView) {
        self.view = view
    }
    
    /// Blank `CGImage` with size of the provided owner view.
    lazy var targetCgImage: CGImage = {
        let renderedImage = UIGraphicsImageRenderer(size: view.frame.size).image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        guard let cgImage = renderedImage.cgImage else {
            fatalError("Failed creating a CGImage.")
        }
        return cgImage
    }()
    
    /// `SIMD2` vec with width and height of the targetCgImage.
    lazy var size: SIMD2<Int> = {
        return SIMD2(targetCgImage.width, targetCgImage.height)
    }()
}
