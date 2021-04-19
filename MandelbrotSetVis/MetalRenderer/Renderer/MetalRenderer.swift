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
    private var paletteTexture: MTLTexture!
    private var samplerState: MTLSamplerState!
    private var bufferProvider: MetalBufferProvider!
    private var isRedrawNeeded = true
    private var vertexBufferProvider: MetalVertexBufferProvider!
    private var bridgeBuffer = RendererBuffer()
    private var performanceMonitor = PerformanceMonitor()
    
    private func loadPalleteTexture(for device: MTLDevice) -> MTLTexture {
        guard let palletePath = Bundle.main.path(forResource: "pallete", ofType: "png") else {
            fatalError("Failed to load pallete.png Check the app's bundle.")
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: palletePath))
            
            guard let image = UIImage(data: data)?.cgImage else {
                fatalError("Failed to load color pallete from image.")
            }
            
            let textureLoader = MTKTextureLoader(device: device)
            let paletteTexture = try textureLoader.newTexture(cgImage: image)
            return paletteTexture
        } catch {
            fatalError("Failed to load pallete texture with error: \(error.localizedDescription)")
        }
    }
}

extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        isRedrawNeeded = true
    }
    
    func draw(in view: MTKView) {
        guard isRedrawNeeded,
              let descriptor = view.currentRenderPassDescriptor,
              let currentDrawable = view.currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }
        
        performanceMonitor.calculationStarted(on: .GPU)

        let buffer = bufferProvider.make(with: bridgeBuffer)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBufferProvider.make(), offset: 0, index: 0)
        commandEncoder.setVertexBuffer(buffer, offset: 0, index: 1)
        commandEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        commandEncoder.setFragmentTexture(paletteTexture, index: 0)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        commandEncoder.endEncoding()
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

        commandQueue = device.makeCommandQueue()
        bufferProvider = MetalBufferProvider(with: device)
        paletteTexture = loadPalleteTexture(for: device)
        vertexBufferProvider = MetalVertexBufferProvider(with: device)
        samplerState = device.makeSamplerState(descriptor: MTLSamplerDescriptor())
        
        let renderPipelineProvider = MetalRenderPipelineProvider(with: device, in: self)
        renderPipelineState = renderPipelineProvider.make()
    }
}
