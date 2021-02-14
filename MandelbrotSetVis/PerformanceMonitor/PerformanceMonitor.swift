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
    private var device: Device?
    var isRunning = false
    
    mutating func calculationStarted(on device: Device) {
        time = CFAbsoluteTimeGetCurrent()
        self.device = device
        isRunning = true
        print("[PERFORMANCE] [\(device.rawValue)] Started rendering frame...")
    }
    
    mutating func calculationEnded() {
        guard let time = time, let device = device else {
            print("[WARNING] calculationEnded() called before calculationStarted().")
            return
        }
        let inference = CFAbsoluteTimeGetCurrent() - time
        self.inference = inference
        isRunning = false
        print("[PERFORMANCE] [\(device.rawValue)] Frame rendered in ", inference, "s.")
    }

    enum Device: String {
        case CPU, GPU
    }
}
