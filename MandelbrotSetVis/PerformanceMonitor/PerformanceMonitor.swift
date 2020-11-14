//
//  File.swift
//  MandelbrotSetVis
//
//  Created by Esie on 11/14/20.
//

import Foundation

struct PerformanceMonitor {
    private var time: TimeInterval?
    private var inference: TimeInterval!
    
    mutating func calculationStarted() {
        time = CFAbsoluteTimeGetCurrent()
    }
    
    mutating func calculationEnded() {
        let inference = CFAbsoluteTimeGetCurrent() - (time ?? 0.0)
        self.inference = inference
        print(inference, "s.")
    }
}
