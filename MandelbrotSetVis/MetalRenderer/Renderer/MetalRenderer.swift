//
//  Renderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

/// Provides the view with mandelbrot image rendered using power of GPU.
final class MetalRenderer: MTKView {
    private var commandQueue: MTLCommandQueue!
    private var renderPipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var paletteTexture: MTLTexture!
    private var samplerState: MTLSamplerState!
    private var bufferProvider: MetalBufferProvider!
    private var isRedrawNeeded = true
    private var vertexBufferProvider: MetalVertexBufferProvider!
    private var bridgeBuffer = RendererBuffer()
    private var performanceMonitor = PerformanceMonitor()
    
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
        performanceMonitor.calculationStarted(on: .GPU)
        
        let clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        currentRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        currentRenderPassDescriptor.colorAttachments[0].clearColor = clearColor
        currentRenderPassDescriptor.colorAttachments[0].storeAction = .store
        currentRenderPassDescriptor.colorAttachments[0].texture = currentDrawable.texture
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
            else { return }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setDepthStencilState(depthStencilState)
        renderCommandEncoder.setVertexBuffer(vertexBufferProvider.make(), offset: 0, index: 0)
        
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

        //FIXME: -[_MTLCommandBuffer addCompletedHandler:], line 673: error '<private>'
//        commandBuffer.addCompletedHandler { [unowned self] _ in
//            performanceMonitor.calculationEnded()
//        }
    }
}

extension MetalRenderer: Renderer {
    var buffer: RendererBuffer {
        get {
            return bridgeBuffer
        }
        set {
            bridgeBuffer = newValue
            isRedrawNeeded = true
        }
    }
    
    func setupRenderer() {
        let deviceProvider = MetalDeviceProvider()
        let device = deviceProvider.make()
        self.device = device
        delegate = self
        depthStencilPixelFormat = .depth32Float_stencil8
        commandQueue = device.makeCommandQueue()
        
        vertexBufferProvider = MetalVertexBufferProvider(device: device)
    
        let sampler = MTLSamplerDescriptor()
        samplerState = device.makeSamplerState(descriptor: sampler)
        
        bufferProvider = MetalBufferProvider(device: device)
        paletteTexture = makeColorPalleteTexture(device: device)
        
        let renderPipelineProvider = MetalRenderPipelineProvider(device: device, view: self)
        renderPipelineState = renderPipelineProvider.make()
        depthStencilState = makeCompiledDepthState(device: device)
    }
}
