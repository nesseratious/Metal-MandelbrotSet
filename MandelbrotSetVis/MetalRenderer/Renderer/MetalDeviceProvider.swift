//
//  MetalDeviceProvider.swift
//  MandelbrotSetVis
//
//  Created by Esie on 2/13/21.
//

import MetalKit

enum GPUDevice {
    
    /// Creates a Metal device GPU representation.
    /// On iOS creates the default device.
    /// On Mac priorities external GPU.
    /// Creates low-power device if battery level is below 20%.
    /// - Returns: MTLDevice device GPU representation.
    static func getDefault() -> MTLDevice {
        #if canImport(AppKit)
        return makeMacDevice()
        #else
        return makeIOSDevice()
        #endif
    }
    
    #if canImport(AppKit)
    static private func makeMacDevice() -> MTLDevice {
        let devices = MTLCopyAllDevices()
        // Detect device battery level, and force using iGPU for calculations if it's below 20%
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        let isNotCharging = UIDevice.current.batteryState != .charging
        if batteryLevel <= 0.2 && isNotCharging {
            // Get iGPU from the devices array
            if let integratedGPU = devices.filter({ $0.isLowPower }).first {
                print("Battery level below 20%, using built-in integrated GPU \(integratedGPU.name), buffer: \(integratedGPU.maxBufferLength/1024/1024)MiB")
                return integratedGPU
            }
            print("Battery level below 20%, but no integrated GPU was found... hackintosh?")
        }
        
        for device in devices {
            
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
        guard let unknownDevice = devices.first else {
            fatalError("Failed to create device.")
        }
        return unknownDevice
    }
    #endif
    
    #if !canImport(AppKit)
    static private func makeIOSDevice() -> MTLDevice {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to create device.")
        }
        print("Using SoC GPU \(device.name)")
        return device
    }
    #endif
}
