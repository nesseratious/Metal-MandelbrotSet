//
//  MetalSamplerProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

struct MetalSamplerProvider {
    private let device: MTLDevice
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func make() -> MTLSamplerState? {
        let sampler = MTLSamplerDescriptor()
        return device.makeSamplerState(descriptor: sampler)
    }
}
