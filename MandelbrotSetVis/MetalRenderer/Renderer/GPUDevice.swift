//
//  GPUDevice.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

enum GPUDevice {
    
    /// Creates a Metal device GPU representation.
    /// On iOS and Macs with Apple Silicon creates the default device.
    /// On intel Macs priorities external GPU. Creates low-power device (iGPU) if battery level is below 20%.
    /// - Returns: `MTLDevice` device.
    static func getDefault() -> MTLDevice {
        #if arch(x86_64)
        return makeIntelMacDevice()
        #elseif arch(arm64)
        return makeAppleSiliconDevice()
        #else
        #error("Unknown arch...")
        #endif
    }
    
    #if arch(x86_64)
    static private func makeIntelMacDevice() -> MTLDevice {
        let gpuDevices = MTLCopyAllDevices()
        // Detect device battery level, and force using iGPU for calculations if it's below 20%
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let isNotCharging = UIDevice.current.batteryState != .charging
        
        if batteryLevel <= 0.2 && isNotCharging {
            // Get iGPU from the devices array
            if let iGPU = gpuDevices.filter({ $0.isLowPower }).first {
                print("Battery level below 20%, using built-in integrated GPU \(iGPU.name), buffer: \(iGPU.maxBufferLength/1024/1024)MiB")
                return iGPU
            }
            print("Battery level below 20%, but no integrated GPU was found... hackintosh?")
        }
        
        for device in gpuDevices {
            
            // External GPU
            if device.isRemovable {
                print("Using external GPU \(device.name), buffer: \(device.maxBufferLength/1024/1024)MiB")
                return device
                
            // Internal descrete GPU
            } else if !device.isLowPower {
                print("Using built-in descrete GPU \(device.name), buffer: \(device.maxBufferLength/1024/1024)MiB")
                return device
                
            // Internal iGPU
            } else {
                print("Using built-in integrated GPU \(device.name), buffer: \(device.maxBufferLength/1024/1024)MiB")
                return device
            }
        }
        
        // If classification above has failed
        guard let unknownDevice = gpuDevices.first else {
            fatalError("Failed to create device.")
        }
        return unknownDevice
    }
    #endif
    
    #if arch(arm64)
    static private func makeAppleSiliconDevice() -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to create device.")
        }
        print("Using SoC's GPU \(device.name)")
        return device
    }
    #endif
}
