//
//  VertexBuffer.h
//  MandelbrotSetVis
//
//  Created by Esie on 8/30/20.
//

#ifndef MetalBuffer_h
#define MetalBuffer_h

typedef struct {
    float x;
    float y;
} Translation;

typedef struct {
    float w;
    float h;
} Scaling;

/// Convertible from Swift using RendererBuffer swift struct.
struct VertexBuffer {
    float scale;
    float iterations;
    Translation translation;
    Scaling aspectRatio;
};

#endif 
