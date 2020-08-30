//
//  Shaders.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

#include "Shaders.h"

vertex OutputVertex vertexShader(const InputVertex inputVertex [[stage_in]],
                                 constant MetalBuffer &buffer [[buffer(1)]],
                                 unsigned int vid [[vertex_id]]) {
    OutputVertex outputVertex;
    auto scale = buffer.scale;
    auto xscale = scale * buffer.aspectRatio.width;
    auto yscale = scale * buffer.aspectRatio.height;
    outputVertex.pos = float4(inputVertex.pos, 1.0f);
    outputVertex.coords.x = inputVertex.pos.x * xscale - buffer.transaltion.x;
    outputVertex.coords.y = inputVertex.pos.y * yscale - buffer.transaltion.y;
    return outputVertex;
}

fragment float4 colorShader(OutputVertex interpolated [[stage_in]],
                            metal::texture2d<float> tex2D [[texture(0)]],
                            constant MetalBuffer &buffer [[buffer(0)]],
                            metal::sampler sampler2D [[sampler(0)]]) {
    auto interations = buffer.interations;
    auto x = interpolated.coords.x;
    auto y = interpolated.coords.y;
    auto colorShift = getColorPalleteCoords(interations, x, y);
    auto paletCoord = float2(colorShift/50.0f, 0);
    auto finalColor = tex2D.sample(sampler2D, paletCoord);
    return finalColor;
}

