import ArgumentParser
import Foundation

struct vantuzModules {
    let allModules: [FetchableModule] = [
        CpuModule(),
        OSVersionModule(),
        MachineModule(),
        OSUptimeModule(),
        OSHostModule()
    ]
    
    func executeAll(enabledIds: [String]) -> [FetchableModule] {
        let _all = enabledIds.contains("all")
        var executed: [FetchableModule] = []
        
        for var module in allModules {
            if enabledIds.contains(module.id) || _all {
                module.run()
                executed.append(module)
            }
        }
        
        return executed
    }
}

@main
struct VantuzFetch: ParsableCommand {
    
    @Flag(name: [.customLong("show-physical-disk-names")], help: "Shows physical names of disks")
    var CONFIG_showPhysicalDiskNames = false

    
    mutating func run() throws {
        let modules = vantuzModules()
            .executeAll(enabledIds: ["all"])
        
        print("vantuz!")
        
        for module in modules {
            if module.isFetched {
                for result in module.results {
                    print("\(result.keyId): \(result.value)")
                }
            }
        }
        
        
        
        print("old vantuz!")
        
//        let osInfo = OsInfo()
//        let cpuInfo = CpuInfo()
//        let model = osInfo.model
//        if let model = model {
//            print("Machine: \(model)")
//        }
//        print("macOS version: \(osInfo.fullVersion) \(osInfo.codename)")
//        print("Host: \(osInfo.hostName)")
//        print("Uptime: \(osInfo.uptimeFormatted)")
//        print("Сpu: \(cpuInfo.name) (\(cpuInfo.getStringifiedClusters()))")
        
        
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
        
        let diskInfo = Disks(fetchPhysicalNames: self.CONFIG_showPhysicalDiskNames)
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
                let physicalName = disk.physicalName != nil ? ", \(disk.physicalName ?? "unknown")" : ""
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
}


