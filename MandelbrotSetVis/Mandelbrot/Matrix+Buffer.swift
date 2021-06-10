//
//  Buffer.swift
//  MandelbrotSetVis
//
//  Created by Denis Esie on 10.06.2021.
//

import Foundation

/// Can be switched to Array or other RandomAccesCollection that implements subsripting
typealias Buffer = UnsafeMutablePointer<FloatType>

actor Matrix {
    let width: Buffer
    let heigh: Buffer
    
    init(width: Buffer, heigh: Buffer) {
        self.width = width
        self.heigh = heigh
    }
}
