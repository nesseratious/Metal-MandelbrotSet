//
//  Renderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

final class MetalRenderer: MTKView {
    private var commandQueue: MTLCommandQueue!
    private var renderPipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var paletteTexture: MTLTexture!
    private var samplerState: MTLSamplerState!
    private var bufferProvider: MetalBufferProvider!
    private var isRedrawNeeded = true
    private var square: Square!
    private var bufferUniform = RendererBuffer()
    
    private func makeColorPalleteTexture(device: MTLDevice) -> MTLTexture {
        guard let path = Bundle.main.path(forResource: "pallete", ofType: "png") else {
            fatalError("Failed to load color pallete. ")
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let textureLoader = MTKTextureLoader(device: device)
            guard let image = UIImage(data: data)?.cgImage else {
                fatalError("Failed to load color pallete from image.")
            }
            let paletteTexture = try textureLoader.newTexture(cgImage: image)
            return paletteTexture
        } catch let error {
            fatalError("Failed to load color pallete texture. Error \(error.localizedDescription)")
        }
    }
    
    private func makeRenderPipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Failed to create a metal library.")
        }
        guard let vertexShader = library.makeFunction(name: "vertexShader"),
              let fragmentShader = library.makeFunction(name: "colorShader") else {
            fatalError("Failed to create a metal vertex and color shaders.")
        }
        return makePipelineState(device: device, vertexShader: vertexShader, fragmentShader: fragmentShader)!
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
    
    
    private func makePipelineState(device: MTLDevice, vertexShader: MTLFunction, fragmentShader: MTLFunction) -> MTLRenderPipelineState? {
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = makeVertexDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexShader
        pipelineStateDescriptor.fragmentFunction = fragmentShader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = depthStencilPixelFormat
        do {
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            return pipelineState
        } catch let error {
            fatalError("Failed to make render pipeline state. Error \(error.localizedDescription)")
        }
    }
    
    private func makeCompiledDepthState(device: MTLDevice) -> MTLDepthStencilState {
        let depthStencilDesc = MTLDepthStencilDescriptor()
        depthStencilDesc.depthCompareFunction = .less
        depthStencilDesc.isDepthWriteEnabled = true
        return device.makeDepthStencilState(descriptor: depthStencilDesc)!
    }
}

extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        isRedrawNeeded = true
    }
    
    func draw(in view: MTKView) {
        guard isRedrawNeeded,
              let currentRenderPassDescriptor = view.currentRenderPassDescriptor,
              let currentDrawable = view.currentDrawable else {
            return
        }
        
        var monitor = PerformanceMonitor()
        monitor.calculationStarted()
        
        let clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        currentRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        currentRenderPassDescriptor.colorAttachments[0].clearColor = clearColor
        currentRenderPassDescriptor.colorAttachments[0].storeAction = .store
        currentRenderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else {
            return
        }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setVertexBuffer(square.vertexBuffer, offset: 0, index: 0)
        
        let uniformBuffer = bufferProvider.make(with: bridgeBuffer)
        renderCommandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        renderCommandEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        renderCommandEncoder.setFragmentTexture(paletteTexture, index: 0)
        renderCommandEncoder.setFragmentSamplerState(samplerState, index: 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderCommandEncoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        isRedrawNeeded = false

        commandBuffer.addCompletedHandler { _ in
            monitor.calculationEnded()
        }
    }
}

extension MetalRenderer: Renderer {
    var bridgeBuffer: RendererBuffer {
        get {
            return bufferUniform
        }
        set {
            bufferUniform = newValue
            isRedrawNeeded = true
        }
    }
    
    func setupRenderer() {
        let device = MetalDeviceProvider.makeDevice()
        self.device = device
        delegate = self
        depthStencilPixelFormat = .depth32Float_stencil8
        commandQueue = device.makeCommandQueue()
        square = Square(device: device)
        let samplerProvider = MetalSamplerProvider(device: device)
        samplerState = samplerProvider.make()
        bufferProvider = MetalBufferProvider(device: device)
        paletteTexture = makeColorPalleteTexture(device: device)
        renderPipelineState = makeRenderPipelineState(device: device)
        depthStencilState = makeCompiledDepthState(device: device)
    }
}
