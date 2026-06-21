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
            CpuModule(cpuConfig: config.cpuConfig),
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
    
    @OptionGroup var flags: FlagOptions
    
    mutating func run() throws {
        let configInitializer = VantuzConfigInitializer()
        let activePaths = configInitializer.loadActivePaths()
        let configFile: vantuzConfig = configInitializer.loadConfig(from: activePaths.configURL)
        
        let finalShowPhysicalDiskNames = flags.showPhysicalDiskNames ?? configFile.diskConfig.showPhysicalDiskNames
        let finalFastDiskSizeCalc = flags.fastDiskSizeCalc ?? configFile.diskConfig.fastVolumeSizeCalculation
        let finalMeasureTime = flags.measureTime ?? configFile.modules.showTimePerformance
        
        var enabledIds: [String] = configFile.modules.modules
        if flags.showAllModules {
            enabledIds.append("all")
        }
        
        let cpuConfig = configFile.cpuConfig
        
        let config = vantuzConfig(
            modules: Modules(modules: enabledIds, showTimePerformance: finalMeasureTime),
            diskConfig: DiskConfig(showPhysicalDiskNames: finalShowPhysicalDiskNames, fastVolumeSizeCalculation: finalFastDiskSizeCalc),
            cpuConfig: cpuConfig
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


