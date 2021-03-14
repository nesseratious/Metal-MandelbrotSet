//
//  Shaders.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

#include <metal_stdlib>
#include "MetalBuffer.h"

using namespace metal;

inline int getColorCoords(const int iterations, const float x, const float y) {
    float real = 0, img = 0;
    int i = 0;
    while (i < iterations && real * real + img * img < 10.0f) {
        float temp = (real * real) - (img * img) + x;
        img = 2.0f * (real * img) + y;
        real = temp;
        i++;
    }
    return i == iterations ? 0 : i;
}

struct VOutput {
    float4 position [[position]];
    float2 coordinates;
};

fragment float4 colorShader(VOutput output [[stage_in]],
                            texture2d<float> pallete,
                            constant MetalBuffer &buffer,
                            sampler sampler) {
    float x = output.coordinates.x;
    float y = output.coordinates.y;
    int colorShift = getColorCoords(buffer.iterations, x, y);
    float2 palleteCoord = float2(colorShift/65.0f, 0);
    float4 finalColor = pallete.sample(sampler, palleteCoord);
    return finalColor;
}

struct VInput {
    float3 position [[attribute(0)]];
};

vertex VOutput vertexShader(const VInput input [[stage_in]],
                            constant MetalBuffer &buffer [[buffer(1)]]) {
    VOutput outputVertex;
    float scale = buffer.scale;
    float xscale = scale * buffer.aspectRatio.w;
    float yscale = scale * buffer.aspectRatio.h;
    outputVertex.position = float4(input.position, 1.0f);
    outputVertex.coordinates.x = input.position.x * xscale - buffer.translation.x;
    outputVertex.coordinates.y = input.position.y * yscale - buffer.translation.y;
    return outputVertex;
}
