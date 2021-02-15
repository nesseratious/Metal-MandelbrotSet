//
//  RowCalculator.c
//  MandelbrotSetVis
//
//  Created by Esie on 2/15/21.
//

#include "RowCalculator.h"

void calculateMandelbrotRow(long row, long rowWidth, float* widthBuffer, float* heightBuffer, unsigned int* targetBuffer, long iterations) {
    for (int column = 0; column < rowWidth; column++) {
        const float my = heightBuffer[row];
        const float mx = widthBuffer[column];
        float real = 0.0;
        float img = 0.0;
        int i = 0;
        
        while (i < iterations) {
            const float r2 = real * real;
            const float i2 = img * img;
            if ((r2 + i2) > 4.0) { break; }
            img = 2.0 * real * img + my;
            real = r2 - i2 + mx;
            i++;
        }
        
        const long pixelOffset = row * rowWidth + column;
        targetBuffer[pixelOffset] = i << 24 | i << 16 | i << 8 | 255 << 0;
    }
}
