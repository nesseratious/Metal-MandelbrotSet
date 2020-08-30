//
//  Mandelbrot.metal
//  MandelbrotSetVis
//
//  Created by Esie on 8/30/20.
//

#include "Calculator.h"

float getColorPalleteCoords(const int interations, const float x, const float y) {
    auto real = 0.0f;
    auto img = 0.0f;
    auto i = 0;
    while (i < interations && real * real + img * img < 10.0f) {
        auto temp = (real * real) - (img * img) + x;
        img = 2.0f * (real * img) + y;
        real = temp;
        i++;
    }
    return i == interations ? 0.0 : (float)i;
}
