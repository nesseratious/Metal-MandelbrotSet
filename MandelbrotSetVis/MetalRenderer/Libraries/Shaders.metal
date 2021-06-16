//
//  Shaders.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

#include <metal_stdlib>
#include "Shaders.h"

using namespace Mandelbrot;

inline int calculate(const MandelbrotVertexData data) {
    float2 complex = float2(0, 0);
    uint i = 0;
    while (i < data.iterations) {
        float2 vec = complex * complex;
        if (vec.x + vec.y > 10.0) { break; }
        float x = vec.x - vec.y;
        float y = 2.0 * complex.x * complex.y;
        complex = float2(x, y) + data.position;
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
                                 constant VertexBuffer &buffer [[buffer(0)]]) {
    uint iterations = (uint)buffer.iterations;
    auto data = MandelbrotVertexData { outputVertex.coordinates, iterations };
    return mandelbrot(data, pallete, sampler);
}

vertex OutputVertex vertexFunction(const InputVertex inputVertex [[stage_in]],
                                   constant VertexBuffer &buffer [[buffer(1)]]) {
    OutputVertex outputVertex;
    float2 scale = buffer.aspectRatio * buffer.scale;
    float2 position = getFloat2(inputVertex.position);
    outputVertex.position = float4(inputVertex.position, 1.0f);
    outputVertex.coordinates = position * scale - buffer.translation;
    return outputVertex;
}
