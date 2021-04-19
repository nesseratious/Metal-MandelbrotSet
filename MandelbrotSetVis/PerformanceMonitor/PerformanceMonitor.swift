//
//  File.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation

struct PerformanceMonitor {
    private var time: TimeInterval?
    private var inference: TimeInterval?
    private var source: Source?
    var isRunning = false
    
    enum Source: String {
        case CPU, GPU
    }
    
    /// Called before each frame render to save the start time and calculate the inference.
    /// - Parameter source: Type of the source (device, algorithm etc)
    mutating func calculationStarted(on source: Source) {
        self.source = source
        time = CFAbsoluteTimeGetCurrent()
        isRunning = true
        print("[PERFORMANCE] [\(source.rawValue)] Started rendering frame...")
    }
    
    /// Called after each frame render finishes.
    mutating func calculationEnded() {
        guard let time = time, let source = source else {
            print("[WARNING] calculationEnded() called before calculationStarted().")
            return
        }
        let inference = CFAbsoluteTimeGetCurrent() - time
        self.inference = inference
        isRunning = false
        print("[PERFORMANCE] [\(source.rawValue)] Frame rendered in ", inference, "s.")
    }
    
    //TODO: Add FPS counter
}
