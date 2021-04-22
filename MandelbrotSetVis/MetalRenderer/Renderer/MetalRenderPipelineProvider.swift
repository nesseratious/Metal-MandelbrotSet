//
//  MetalRenderPipelineState.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

struct MetalRenderPipelineProvider {
    private unowned let device: MTLDevice
    private unowned let view: MTKView
    
    init(with device: MTLDevice, in view: MTKView) {
        self.device = device
        self.view = view
    }
    
    /// Creates a Metal pipeline state for render with vertex and color shaders.
    /// - Returns: Metal pipeline state for render.
    func make() -> MTLRenderPipelineState {
        let vertexFunction = makeVertexFunction()
        let colorFunction = makeColorFunction()
        let despriptor = makePipelineDescriptor(vertexFunction: vertexFunction, colorFunction: colorFunction)
        return makePipelineState(device: device, descriptor: despriptor)
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
              let colorFunction = library.makeFunction(name: "fragmentFunction") else {
            fatalError("Failed to create metal color function")
        }
        return colorFunction
    }
    
    private func makePipelineDescriptor(vertexFunction: MTLFunction, colorFunction: MTLFunction) -> MTLRenderPipelineDescriptor {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexDescriptor = makeVertexDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = colorFunction
        descriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        return descriptor
    }
    
    private func makePipelineState(device: MTLDevice, descriptor: MTLRenderPipelineDescriptor) -> MTLRenderPipelineState {
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
        vertexDescriptor.layouts[0]?.stride = MemoryLayout<Float32>.stride * 3
        return vertexDescriptor
    }
}
