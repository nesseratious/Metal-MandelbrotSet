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
    
    /// Creates a Metal pipeline state for render with vertex and color shaders.
    /// - Returns: Metal pipeline state for render.
    func make() -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Failed to create a metal library.")
        }
        guard let vertexShader = library.makeFunction(name: "vertexFunction"),
              let fragmentShader = library.makeFunction(name: "colorFunction") else {
            fatalError("Failed to create metal vertex and color functions.")
        }
        return makePipelineState(device: device, vertexShader: vertexShader, fragmentShader: fragmentShader)
    }
    
    private func makePipelineState(device: MTLDevice, vertexShader: MTLFunction, fragmentShader: MTLFunction) -> MTLRenderPipelineState {
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
            fatalError("Failed to make render pipeline state with error: \(error.localizedDescription)")
        }
    }
    
    private func makeVertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0]?.format = .float2
        vertexDescriptor.layouts[0]?.stride = MemoryLayout<Float>.stride * 3
        return vertexDescriptor
    }
}
