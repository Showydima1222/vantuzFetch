import Foundation
import Metal

class GPUParser {
    static func getDeivces() -> [MTLDevice] {
        return MTLCopyAllDevices()
    }
    
}

struct GPUDevice {
    let name: String
    let coresAmount: Int
    let isUsingUnifiedMemory: Bool
    let isIgpu: Bool
    let architecture: String
}


class GPUInfo {
    let deivces: [GPUDevice]
    init() {
        var buffer: [GPUDevice] = []
        for device in GPUParser.getDeivces() {
            let isIgpu = device.isLowPower && !device.isRemovable
            var deviceArchitecture: String = ""
            if #available(macOS 14.0, *) {
                deviceArchitecture = device.architecture.name
            }
            buffer.append(GPUDevice(
                name: device.name, coresAmount: 0, isUsingUnifiedMemory: device.hasUnifiedMemory, isIgpu: isIgpu,
                architecture: deviceArchitecture
            ))
            
        }
        self.deivces = buffer
    }
}
