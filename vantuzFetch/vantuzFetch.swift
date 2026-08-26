import ArgumentParser
import Foundation
import Darwin


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
            KernelModule(showBuildDate: config.kernelConfig.showBuildDate),
            MachineModule(),
            OSUptimeModule(),
            WakeTimeModule(),
            OSHostModule(),
            ShellModule(),
            TerminalModule(),
            GPUModule(),
            DisplayModule(),
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
    
    private static let VERSION = 10000
    static var version: String {
        let major = VantuzFetch.VERSION / 10000
        let minor = (VantuzFetch.VERSION % 10000) / 100
        let patch = (VantuzFetch.VERSION % 100)
        return "\(major).\(minor).\(patch)"
    }
    
    mutating func run() throws {
        let configInitializer = VantuzConfigInitializer()
        let activePaths = configInitializer.loadActivePaths()
        let configFile: vantuzConfig = configInitializer.loadConfig(from: activePaths.configURL)
        let themeFile: vantuzTheme = configInitializer.loadTheme(from: activePaths.themeURL)
        
        if flags.showVersion ?? false {
            print("Current vantuzfetch version is \(VantuzFetch.version)")
            return
        }
        
        let finalShowPhysicalDiskNames = flags.showPhysicalDiskNames ?? configFile.diskConfig.showPhysicalDiskNames
        let finalFastDiskSizeCalc = flags.fastDiskSizeCalc ?? configFile.diskConfig.fastVolumeSizeCalculation
        let finalMeasureTime = flags.measureTime ?? configFile.modules.showTimePerformance
        let finalShowKernelBuildDate = flags.showKernelBuildDate ?? configFile.kernelConfig.showBuildDate
        
        var enabledIds: [String] = configFile.modules.modules
        if flags.showAllModules {
            enabledIds.append("all")
        }
        
        let cpuConfig = configFile.cpuConfig
        
        let config = vantuzConfig(
            modules: Modules(modules: enabledIds, showTimePerformance: finalMeasureTime),
            diskConfig: DiskConfig(showPhysicalDiskNames: finalShowPhysicalDiskNames, fastVolumeSizeCalculation: finalFastDiskSizeCalc),
            cpuConfig: cpuConfig,
            kernelConfig: KernelConfig(showBuildDate: finalShowKernelBuildDate)
        )
        let modules = vantuzModules(config: config)
            .executeModules(enabledIds: enabledIds)
        
        print("vantuz!")
        
        let vantuzRender = vantuzRender(theme: themeFile, logo: Logotypes.shared.getLogotype("Apple"))
        vantuzRender.renderAllModules(modules: modules)
    }
}


