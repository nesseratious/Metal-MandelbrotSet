//
//  MetalSamplerProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

/// Provides a Metal MTLSamplerState
struct MetalSamplerProvider {
    private let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    /// Creates MTLSamplerState.
    /// - Returns: MTLSamplerState.
    func make() -> MTLSamplerState? {
        let sampler = MTLSamplerDescriptor()
        return device.makeSamplerState(descriptor: sampler)
    }
}
