//
//  Matrix+Buffer.swift
//  MandelbrotSetVis
//
//  Created by Denis Esie on 10.06.2021.
//

/// Can be switched to Array or other RandomAccesCollection that implements subsripting
typealias Buffer = UnsafeMutablePointer<FloatType>

struct Matrix {
    let width: Buffer
    let heigh: Buffer
}
