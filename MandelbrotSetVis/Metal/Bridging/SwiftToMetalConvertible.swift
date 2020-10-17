//
//  SwiftToMetalConverrtible.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/29/20.
//

import Foundation

protocol SwiftToMetalConvertible {
    var unsafeRawData: [Float32] { get }
}

extension SwiftToMetalConvertible {
    func getRawData() -> [Float32] {
        let metalBufferSize = MemoryLayout<MetalBuffer>.size
        unsafeRawData.withUnsafeBufferPointer {
            guard let baseAdress = $0.baseAddress else {
                fatalError("Swift buffer is empty.")
            }
            let stride = MemoryLayout<Float32>.stride
            let size = Data(bytes: baseAdress, count: unsafeRawData.count * stride).count
            guard metalBufferSize == size else {
                fatalError("Swift buffer and Metal buffer have different memory layouts.")
            }
        }
        return unsafeRawData
    }
}
