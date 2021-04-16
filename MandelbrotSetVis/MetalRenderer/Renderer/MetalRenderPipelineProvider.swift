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
        let colorFunction = makeColorFunction()
        let vertexFunction = makeVertexFunction()
        return makePipelineState(device: device, vertexFunction: vertexFunction, colorFunction: colorFunction)
    }
    
    private func makeVertexFunction() -> MTLFunction {
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexFunction") else {
            fatalError("Failed to create metal vertex function")
        }
        return vertexFunction
    }
    
    private func makeColorFunction() -> MTLFunction {
        guard let library = device.makeDefaultLibrary(),
              let colorFunction = library.makeFunction(name: "colorFunction") else {
            fatalError("Failed to create metal color function")
        }
        return colorFunction
    }
    
    private func makePipelineState(device: MTLDevice, vertexFunction: MTLFunction, colorFunction: MTLFunction) -> MTLRenderPipelineState {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexDescriptor = makeVertexDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = colorFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
            return pipelineState
        } catch {
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
