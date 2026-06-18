import ArgumentParser
import Foundation

struct vantuzModules {
    
    let config: vantuzConfig
    let allModules: [FetchableModule]
    let modulesOrdered: [String: FetchableModule]
    
    init (config: vantuzConfig) {
        self.config = config
        self.allModules = [
            OSVersionModule(),
            KernelModule(),
            MachineModule(),
            OSUptimeModule(),
            OSHostModule(),
            ShellModule(),
            TerminalModule(),
            GPUModule(),
            DisksModule(showPhysicalDiskNames: config.diskConfig.showPhysicalDiskNames, fastVolumeSizeCalculation: config.diskConfig.fastVolumeSizeCalculation),
            CpuModule(),
            MemoryModule()
        ]
        self.modulesOrdered = Dictionary(uniqueKeysWithValues: allModules.map { ($0.id, $0) })
    }
        
    func executeModules(enabledIds: [String]) -> [[FetchResult]] {
        let _all = enabledIds.contains("all")
        var executed: [[FetchResult]] = []
        
        if _all {
            for module in self.allModules {
                let executedModule = module.run()
                if !executedModule.isEmpty {
                    executed.append(executedModule)
                }
            }
            return executed
        }
        for id in enabledIds {
            if let module = self.modulesOrdered[id] {
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
    
    @Flag(name: [.customLong("fast-disk-size-calc")], help: "Using fast calculation of disk size without calculating deletable cache")
    var fastDiskSizeCacl = false
    @Flag(name: [.customLong("slow-disk-size-calc")], help: "Using slower calculation of disk size with calculating deletable cache")
    var slowDiskSizeCacl = false
    
    @Flag(name: [.customLong("all")], help: "Show all modules")
    var showyAllModules = false
    
    
    
    mutating func run() throws {
        let configInitializer = VantuzConfigInitializer()
        let activePaths = configInitializer.loadActivePaths()
        let configFile: vantuzConfig = configInitializer.loadConfig(from: activePaths.configURL)
        
        var finalShowPhysicalDiskNames = configFile.diskConfig.showPhysicalDiskNames
        if showPhysicalDiskNames { finalShowPhysicalDiskNames = true }
        else if hidePhysicalDiskNames { finalShowPhysicalDiskNames = false }
        
        var finalfastDiskSizeCacl = configFile.diskConfig.fastVolumeSizeCalculation
        if fastDiskSizeCacl { finalfastDiskSizeCacl = true }
        else if slowDiskSizeCacl { finalfastDiskSizeCacl = false }
        
        var enabledIds: [String] = configFile.modules.modules
        if showyAllModules { enabledIds.append("all") }
        
        let config = vantuzConfig(
            diskConfig: DiskConfig(showPhysicalDiskNames: finalShowPhysicalDiskNames, fastVolumeSizeCalculation: finalfastDiskSizeCacl)
        )
        let modules = vantuzModules(config: config)
            .executeModules(enabledIds: enabledIds)
        
        print("vantuz!")
        
        for executed in modules {
            for result in executed {
                print("\(result.keyId): \(result.value)")
            }
        }
    }
}


