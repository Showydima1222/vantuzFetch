import Foundation
import Metal

class GPUParser {
    static func getDeivces() -> [MTLDevice] {
        return MTLCopyAllDevices()
    }
}

//struct GPUDevice {
//    let name: String
//    let coresAmount: Int
//    let isUsingUnifiedMemory: Bool
//    let isIgpu: Bool
//    let architecture: String
//}


struct GPUModule: FetchableModule {
    let id: String = "gpu"
    var isFetched: Bool = false
    var results: [FetchResult] = []
    
    mutating func run() {
        var i: Int = 0
        for device in GPUParser.getDeivces() {
            let isIgpu = device.isLowPower && !device.isRemovable
            var deviceArchitecture: String = ""
            if #available(macOS 14.0, *) {
                deviceArchitecture = device.architecture.name
            }
            let unifiedMemory: String = device.hasUnifiedMemory ? "[Unified Memory]" : ""
            self.results.append(FetchResult(keyId: "\(self.id)_\(i)", value: "\(device.name)\(unifiedMemory) (\(deviceArchitecture)"))
            i = i + 1
        }
        self.isFetched = !self.results.isEmpty
    }
    
}
//
//class GPUInfo {
////    let deivces: [GPUDevice]
//    init() {
//        var buffer: [GPUDevice] = []
//        for device in GPUParser.getDeivces() {
//            let isIgpu = device.isLowPower && !device.isRemovable
//            var deviceArchitecture: String = ""
//            if #available(macOS 14.0, *) {
//                deviceArchitecture = device.architecture.name
//            }
//            buffer.append(GPUDevice(
//                name: device.name, coresAmount: 0, isUsingUnifiedMemory: device.hasUnifiedMemory, isIgpu: isIgpu,
//                architecture: deviceArchitecture
//            ))
//            
//        }
//        self.deivces = buffer
//    }
//}
