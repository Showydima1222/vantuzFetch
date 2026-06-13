import Foundation
import Metal

class GPUParser {
    static func getDeivces() -> [MTLDevice] {
        return MTLCopyAllDevices()
    }
}

struct GPUModule: FetchableModule {
    let id: String = "gpu"
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        var i: Int = 0
        for device in GPUParser.getDeivces() {
//            let isIgpu = device.isLowPower && !device.isRemovable
            var deviceArchitecture: String = ""
            if #available(macOS 14.0, *) {
                deviceArchitecture = device.architecture.name
            }
            let unifiedMemory: String = device.hasUnifiedMemory ? "[Unified Memory]" : ""
            results.append(FetchResult(keyId: "\(self.id)_\(i)", value: "\(device.name)\(unifiedMemory) (\(deviceArchitecture)"))
            i = i + 1
        }
        return results
    }
}
