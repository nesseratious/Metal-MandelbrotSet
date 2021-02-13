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
    
    mutating func calculationStarted() {
        time = CFAbsoluteTimeGetCurrent()
        print("[PERFORMANCE] Started rendering frame...")
    }
    
    mutating func calculationEnded() {
        guard let time = time else {
            print("[WARNING] calculationEnded() called before calculationStarted().")
            return
        }
        let inference = CFAbsoluteTimeGetCurrent() - time
        self.inference = inference
        print("[PERFORMANCE] Frame rendered in ", inference, "s.")
    }
}
