import ArgumentParser
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
    print("Uptime: \(osInfo.uptimeFormatted)")
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
        let totalGb = Double(memInfo.info!.total).asGiB().asFormattedString()
        let usedGb = Double(memInfo.info!.usedMemory).asGiB().asFormattedString()
        print("Memory: \(totalGb)GB total, \(usedGb)GB used")
        
    }
    
    let diskInfo = Disks()
    if diskInfo.isParsed {
        var orderedDisks = diskInfo.info!.sorted {
            (lhs, rhs) -> Bool in
            func priority (for disk: DiskInfo) -> Int {
                if disk.isSystemVolume { return 0 }
                if disk.isInternal { return 1 }
                return 2
            }
            let p1 = priority(for: lhs)
            let p2 = priority(for: rhs)
            if p1 != p2 { return p1 < p2 }
            
            return lhs.volumeName.localizedCompare(rhs.volumeName) == .orderedAscending
        }
        
        for disk in orderedDisks {
            let name = disk.volumeName
            let physicalName = disk.physicalName != nil ? ", \(disk.physicalName)" : ""
            let totalGb = Double(disk.total).asGB().asFormattedString()
            let userGb = Double(disk.usedSpace).asGB().asFormattedString()
            let isSystemDisk = disk.isSystemVolume ? " (System)" : ""
            let isInternal = disk.isInternal ? " (Internal)" : " (External)"
            let isReadOnly = disk.isReadOnly ? " (ReadOnly)" : ""
            let usedPercent = Int(round(disk.usedSpace.asGB() / disk.total.asGB() * 100))
            print("Disk (\(name)\(physicalName)): \(userGb)GB / \(totalGb)GB (\(usedPercent)%)\(isSystemDisk)\(isInternal)\(isReadOnly)")
        }
    }
    
}

//@main
//class Vantuz {
//    static func main() {
//        mainSS()
//    }
//}

@main
struct VantuzFetch: ParsableCommand {
    mutating func run() throws {
        mainSS()
    }
}


