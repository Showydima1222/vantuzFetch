import ArgumentParser
import Foundation

struct vantuzModules {
    
    let config: vantuzConfig
    let allModules: [FetchableModule]
    
    init (config: vantuzConfig) {
        self.config = config
        self.allModules = [
            OSVersionModule(),
            MachineModule(),
            OSUptimeModule(),
            OSHostModule(),
            GPUModule(),
            DisksModule(showPhysicalDiskNames: self.config.showPhysicalDiskNames),
            CpuModule(),
            MemoryModule()
        ]

    }
        
    func executeAll(enabledIds: [String]) -> [[FetchResult]] {
        let _all = enabledIds.contains("all")
        var executed: [[FetchResult]] = []
        
        for module in self.allModules {
            if enabledIds.contains(module.id) || _all {
                let executedModule = module.run()
                if !executedModule.isEmpty {
                    executed.append(executedModule)
                }
            }
        }
        return executed
    }
}

@main
struct VantuzFetch: ParsableCommand {
    
    @Flag(name: [.customLong("show-physical-disk-names")], help: "Shows physical names of disks")
    var showPhysicalDiskNames = false
    @Flag(name: [.customLong("hide-physical-disk-names")], help: "Hides physical names of disks")
    var hidePhysicalDiskNames = false
    
    
    mutating func run() throws {
        let configInitializer = VantuzConfigInitializer()
        let activePaths = configInitializer.loadActivePaths()
        let configFile: vantuzConfig = configInitializer.loadConfig(from: activePaths.configURL)
        
        var finalShowPhysicalDiskNames = configFile.showPhysicalDiskNames
        if showPhysicalDiskNames { finalShowPhysicalDiskNames = true }
        else if hidePhysicalDiskNames { finalShowPhysicalDiskNames = false }
        
        let config = vantuzConfig(showPhysicalDiskNames: finalShowPhysicalDiskNames)
        let modules = vantuzModules(config: config)
            .executeAll(enabledIds: ["all"])
        
        print("vantuz!")
        
        for executed in modules {
            for result in executed {
                print("\(result.keyId): \(result.value)")
            }
        }
    }
}


