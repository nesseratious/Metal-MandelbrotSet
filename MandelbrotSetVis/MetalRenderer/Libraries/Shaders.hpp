//
//  Mandelbrot.metal
//  MandelbrotSetVis
//
//  Created by Esie on 4/19/21.
//

#ifndef Shaders_h
#define Shaders_h

#import <simd/simd.h>
#import <metal_stdlib>

namespace Mandelbrot {

/// Convertible from Swift using VertexBuffer swift struct.
struct VertexBuffer {
    float scale;
    float iterations;
    float2 translation;
    float2 aspectRatio;
};

struct MandelbrotVertexData {
    float2 position;
    uint iterations;
};

struct InputVertex {
    float3 position [[attribute(0)]];
};

struct OutputVertex {
    float4 position [[position]];
    float2 coordinates;
};

}

METAL_FUNC float2 getFloat2(float3 vec) {
    return float2(vec.x, vec.y);
}

#endif
