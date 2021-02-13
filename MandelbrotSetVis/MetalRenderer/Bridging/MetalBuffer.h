//
//  MetalBuffer.h
//  MandelbrotSetVis
//
//  Created by Esie on 8/30/20.
//

#ifndef MetalBuffer_h
#define MetalBuffer_h

struct Translation {
    float x;
    float y;
};

struct AspectRatioScaling {
    float width;
    float height;
};

/// Size 192 bits.
/// Stride 192 bits.
/// Convertible from Swift using 6 x 32 buffer [Scale, Iterations, X, Y, W, H]
struct MetalBuffer {
    float scale;
    float interations;
    struct Translation transaltion;
    struct AspectRatioScaling aspectRatio;
};

#endif 
