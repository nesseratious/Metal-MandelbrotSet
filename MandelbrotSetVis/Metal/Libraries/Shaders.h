//
//  Shaders.swift
//  MandelbrotSetVis
//
//  Created by Esie on 8/26/20.
//  Copyright © 2020 Denis Esie. All rights reserved.
//

#ifndef Shaders_h
#define Shaders_h
#include <metal_stdlib>
#include <metal_math>
#include "Calculator.h"
#include "../Bridging/MetalBuffer.h"

struct InputVertex {
    float3 pos [[attribute(0)]];
};

struct OutputVertex {
    float4 pos [[position]];
    float2 coords;
};

#endif
