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
    
    /// Blank CGImage with size of the provided owner view.
    lazy var targetCgImage: CGImage = {
        UIGraphicsImageRenderer(size: view.frame.size).image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }.cgImage!
    }()
    
    /// Tuple with width, height of the cgImage image.
    lazy var size: (width: Int, height: Int) = {
        return (width: targetCgImage.width, height: targetCgImage.height)
    }()
}
