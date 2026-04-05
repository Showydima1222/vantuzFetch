//import ArgumentParser
import Foundation

func mainSS() {
    print("vantuz!")
    
    let osInfo = OsInfo()
    let cpuInfo = CpuInfo()
    let model = osInfo.model
    if let model = model {
        print("Machine: \(model)")
    }
    print("macOS version: \(osInfo.fullVersion) \(osInfo.codename)")
    print("Host: \(osInfo.hostName)")
    print("uptime: \(osInfo.uptimeFormatted)")
    print("Сpu: \(cpuInfo.name) (\(cpuInfo.getStringifiedClusters()))")
    
    
    let gpuInfo = GPUInfo()
    let devices = gpuInfo.deivces // consider renaming to 'devices' everywhere

    for (index, device) in devices.enumerated() {
        let label = devices.count == 1 ? "GPU" : "GPU (\(index + 1))"
        let unifiedMemory = device.isUsingUnifiedMemory ? "[Unified Memory]" : ""
        print("\(label): \(device.name) \(unifiedMemory) \(device.architecture)")
    }
    
    let memInfo = Memory()
    if memInfo.isParsed {
        let totalGb = Double(memInfo.info!.total).asGiB()
        let usedGb = Double(memInfo.info!.usedMemory).asGiB().asFormattedString()
        print("Memory: \(totalGb)GB total, \(usedGb)GB used")
        
    }
}

@main
class Vantuz {
    static func main() {
        mainSS()
    }
}

//@main
//struct VantuzFetch: ParsableCommand {
//    mutating func run() throws {
//        mainSS()
//    }
//}
//

