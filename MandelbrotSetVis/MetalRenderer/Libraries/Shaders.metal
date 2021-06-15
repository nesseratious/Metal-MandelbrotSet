//
//  Shaders.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

#include <metal_stdlib>
#include "VertexBuffer.h"
#include "Shaders.h"

inline int calculate(const MandelbrotVertexData data) {
    float real = 0, img = 0;
    int i = 0;
    while (i < data.iterations && real * real + img * img < 10.0f) {
        float temp = (real * real) - (img * img) + data.position.x;
        img = 2.0f * (real * img) + data.position.y;
        real = temp;
        i++;
    }
    return i == data.iterations ? 0 : i;
}

inline float4 mandelbrot(const MandelbrotVertexData data,
                         metal::texture2d<float> pallete,
                         metal::sampler sampler) {
    int colorShift = calculate(data);
    float2 palleteCoords = float2(colorShift/65.0f, 0);
    return pallete.sample(sampler, palleteCoords);;
}

fragment float4 fragmentFunction(OutputVertex outputVertex [[stage_in]],
                                 metal::texture2d<float> pallete,
                                 metal::sampler sampler,
                                 constant VertexBuffer &buffer) {
    float x = outputVertex.coordinates.x;
    float y = outputVertex.coordinates.y;
    int iterations = (int)buffer.iterations;
    auto data = MandelbrotVertexData { float2(x,y), iterations };
    return mandelbrot(data, pallete, sampler);
}

vertex OutputVertex vertexFunction(const InputVertex inputVertex [[stage_in]],
                                   constant VertexBuffer &buffer [[buffer(1)]]) {
    OutputVertex outputVertex;
    float scale = buffer.scale;
    float xscale = scale * buffer.aspectRatio.w;
    float yscale = scale * buffer.aspectRatio.h;
    outputVertex.position = float4(inputVertex.position, 1.0f);
    outputVertex.coordinates.x = inputVertex.position.x * xscale - buffer.translation.x;
    outputVertex.coordinates.y = inputVertex.position.y * yscale - buffer.translation.y;
    return outputVertex;
}
