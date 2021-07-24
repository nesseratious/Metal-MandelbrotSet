//
//  MetalRenderer.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

import MetalKit

/// Provides the view with mandelbrot image rendered using power of GPU.
final class MetalRenderer: MTKView, Renderer {
    private var isRedrawNeeded = true
    private var performanceMonitor = PerformanceMonitor()
    private lazy var defaultDevice = GPUDevice.getDefault()
    private lazy var commandQueue = defaultDevice.makeCommandQueue()
    private lazy var bufferProvider = MetalBufferProvider(with: defaultDevice)
    private lazy var vertexBufferProvider = MetalVertexBufferProvider(with: defaultDevice)
    private lazy var samplerState = defaultDevice.makeSamplerState(descriptor: MTLSamplerDescriptor())
    private lazy var renderPipelineProvider = MetalRenderPipelineProvider(with: defaultDevice, in: self)
    private lazy var renderPipelineState = renderPipelineProvider.make()
    
    var vertexBuffer = VertexBuffer() {
        didSet {
            isRedrawNeeded = true
        }
    }
    
    func setupRenderer() {
        device = defaultDevice
        delegate = self
    }
    
    private lazy var paletteTexture: MTLTexture = {
        guard let palletePath = Bundle.main.path(forResource: "pallete", ofType: "png") else {
            fatalError("Failed to load pallete.png. Check the app's bundle.")
        }
        do {
            let url = URL(fileURLWithPath: palletePath)
            let data = try Data(contentsOf: url)
            
            guard let image = UIImage(data: data)?.cgImage else {
                fatalError("Failed to load color pallete.")
            }
            
            let textureLoader = MTKTextureLoader(device: defaultDevice)
            let paletteTexture = try textureLoader.newTexture(cgImage: image)
            return paletteTexture
        } catch {
            fatalError("Failed to load pallete texture with error: \(error.localizedDescription)")
        }
    }()
}

extension MetalRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        isRedrawNeeded = true
    }
    
    func draw(in view: MTKView) {
        guard isRedrawNeeded,
              let descriptor = view.currentRenderPassDescriptor,
              let currentDrawable = view.currentDrawable,
              let commandBuffer = commandQueue?.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else { return }
        
        performanceMonitor.calculationStarted(on: .GPU)

        let buffer = bufferProvider.make(with: vertexBuffer)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBufferProvider.make(), offset: 0, index: 0)
        commandEncoder.setVertexBuffer(buffer, offset: 0, index: 1)
        commandEncoder.setFragmentBuffer(buffer, offset: 0, index: 0)
        commandEncoder.setFragmentTexture(paletteTexture, index: 0)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        isRedrawNeeded = false
        
        commandBuffer.addCompletedHandler { [weak self] _ in
            self?.performanceMonitor.calculationEnded()
        }

        commandEncoder.endEncoding()
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}
