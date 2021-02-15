//
//  RowCalculator.h
//  MandelbrotSetVis
//
//  Created by Esie on 2/15/21.
//

/// Performs calculation of a single mandolbrot row.
/// @param row Row index.
/// @param rowWidth Row width in pixels.
/// @param widthBuffer  Float32 buffer of current mandebrot width transformation.
/// @param heightBuffer Float32 buffer of current mandebrot heigh transformation.
/// @param targetBuffer Target buffer where the result should be written to.
/// @param iterations Number of mandelbrot iterations.
void calculateMandelbrotRow(long row, long rowWidth, float* widthBuffer, float* heightBuffer, unsigned int* targetBuffer, long iterations);
