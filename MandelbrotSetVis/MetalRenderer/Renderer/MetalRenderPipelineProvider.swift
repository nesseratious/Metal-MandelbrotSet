//
//  MetalRenderPipelineState.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

struct MetalRenderPipelineProvider {
    private let device: MTLDevice
    private let view: MTKView
    
    init(device: MTLDevice, view: MTKView) {
        self.device = device
        self.view = view
    }
    
    func make() -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Failed to create a metal library.")
        }
        guard let vertexShader = library.makeFunction(name: "vertexShader"),
              let fragmentShader = library.makeFunction(name: "colorShader") else {
            fatalError("Failed to create a metal vertex and color shaders.")
        }
        return makePipelineState(device: device, vertexShader: vertexShader, fragmentShader: fragmentShader)!
    }
    
    private func makePipelineState(device: MTLDevice, vertexShader: MTLFunction, fragmentShader: MTLFunction) -> MTLRenderPipelineState? {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = makeVertexDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            return pipelineState
        } catch let error {
            fatalError("Failed to make render pipeline state. Error \(error.localizedDescription)")
        }
    }
    
    private func makeVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        guard let attribute = vertexDescriptor.attributes[0],
              let layout = vertexDescriptor.layouts[0] else {
            fatalError("Failed to create attribute or layout.")
        }
        attribute.format = .float3
        attribute.offset = 0
        attribute.bufferIndex = 0
        layout.stride = MemoryLayout<Float>.size * 3
        return vertexDescriptor
    }
}
