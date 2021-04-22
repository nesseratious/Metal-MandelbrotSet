//
//  Mandelbrot.metal
//  MandelbrotSetVis
//
//  Created by Esie on 4/19/21.
//

#ifndef Shaders_h
#define Shaders_h

#include <metal_stdlib>
#include "MetalBuffer.h"

struct InputVertex {
    float3 position [[attribute(0)]];
};

struct OutputVertex {
    float4 position [[position]];
    float2 coordinates;
};

struct MandelbrotVertexData {
    float2 position;
    int iterations;
};

#endif
