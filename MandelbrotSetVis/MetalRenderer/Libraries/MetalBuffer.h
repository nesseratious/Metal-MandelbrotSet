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

struct Scaling {
    float x;
    float y;
};

/// Convertible from Swift using RendererBuffer swift struct.
struct MetalBuffer {
    float scale;
    float iterations;
    struct Translation translation;
    struct Scaling aspectRatio;
};

#endif 
