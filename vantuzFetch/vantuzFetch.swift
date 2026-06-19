import ArgumentParser
import Foundation


private final class SafeStorage: @unchecked Sendable {
    private let lock = NSLock()
    var items: [(index: Int, results: [FetchResult])] = []
    
    func append(index: Int, results: [FetchResult]) {
        lock.lock()
        items.append((index: index, results: results))
        lock.unlock()
    }
}

struct vantuzModules {
    
    let config: vantuzConfig
    let allModules: [FetchableModule]
    let modulesOrdered: [String: FetchableModule]
    let showTime: Bool
    
    init (config: vantuzConfig) {
        self.config = config
        self.showTime = config.modules.showTimePerformance
        self.allModules = [
            OSVersionModule(),
            KernelModule(),
            MachineModule(),
            OSUptimeModule(),
            WakeTimeModule(),
            OSHostModule(),
            ShellModule(),
            TerminalModule(),
            GPUModule(),
            DisksModule(showPhysicalDiskNames: config.diskConfig.showPhysicalDiskNames, fastVolumeSizeCalculation: config.diskConfig.fastVolumeSizeCalculation),
            CpuModule(),
            MemoryModule(),
            SwapModule(),
        ]
        self.modulesOrdered = Dictionary(uniqueKeysWithValues: allModules.map { ($0.id, $0) })
    }
        
    func executeModules(enabledIds: [String]) -> [[FetchResult]] {
        let _all = enabledIds.contains("all")
        let targets = _all ? self.allModules : enabledIds.compactMap { self.modulesOrdered[$0] }
        
        if targets.isEmpty { return [] }
        
        let storage = SafeStorage()
        let startTotal = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.concurrentPerform(iterations: targets.count) { index in
            let executedModule = targets[index].run()
            
            if !executedModule.isEmpty {
                storage.append(index: index, results: executedModule)
            }
        }
        
        if showTime {
            print("Total: \(String(format: "%.5fs", CFAbsoluteTimeGetCurrent() - startTotal))")
        }
        
        return storage.items
            .sorted { $0.index < $1.index }
            .map { $0.results }
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
    
    @Flag(name: [.customLong("time")], help: "Meansures time of fetching")
    var meansureTime = false
    
    @Flag(name: [.customLong("hide-time")], help: "Hides meansure of time")
    var HidemeansureTime = false
    
    
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
        
        var finalMeansureTime = configFile.modules.showTimePerformance
        if meansureTime { finalMeansureTime = true }
        else if HidemeansureTime { finalMeansureTime = false }
        
        var enabledIds: [String] = configFile.modules.modules
        if showyAllModules { enabledIds.append("all") }
        
        let config = vantuzConfig(
            modules: Modules(modules: enabledIds, showTimePerformance: finalMeansureTime),
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


