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


struct vantuzRender {
    static let ansiSystemColors: [String: String] = [
        "black": "30", "red": "31", "green": "32", "yellow": "33",
        "blue": "34", "magenta": "35", "cyan": "36", "white": "37",
        "bright_black": "90", "bright_red": "91", "bright_green": "92", "bright_yellow": "93",
        "bright_blue": "94", "bright_magenta": "95", "bright_cyan": "96", "bright_white": "97"
    ]
    static let reset = "\u{001B}[0m"
    let theme: vantuzTheme
    let terminalSize: (rows: UInt16, cols: UInt16)
    let isColorSupported: Bool
    let validColors: vantuzColors
    
    static func _parseHex(_ colorValue: String, fallbackColor: String = "\u{001B}[0m") -> String {
        let cleanedInput = colorValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let colorLower = cleanedInput.lowercased()
        
        if let systemCode = vantuzRender.ansiSystemColors[colorLower] {
            return "\u{001B}[\(systemCode)m"
        }
        
        var hexStr = cleanedInput.uppercased()
        if hexStr.hasPrefix("#") {
            hexStr.removeFirst()
        }
        
        let range = NSRange(location: 0, length: hexStr.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[0-9A-F]{3}$|^[0-9A-F]{6}$")
        
        guard regex.firstMatch(in: hexStr, options: [], range: range) != nil else {
            return fallbackColor
        }
        
        if hexStr.count == 3 {
            hexStr = hexStr.map { String($0) + String($0) }.joined()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&rgbValue)
        
        let r = Int((rgbValue & 0xFF0000) >> 16)
        let g = Int((rgbValue & 0x00FF00) >> 8)
        let b = Int(rgbValue & 0x0000FF)
        
        return "\u{001B}[38;2;\(r);\(g);\(b)m"
    }
    
    init(theme: vantuzTheme) {
        self.theme = theme
        self.terminalSize = vantuzRender._getTerminalSize()
        self.isColorSupported = isatty(STDOUT_FILENO) == 1
        
        validColors = vantuzColors(
            title: vantuzRender._parseHex(theme.colors.title, fallbackColor: "yellow"),
            accent: vantuzRender._parseHex(theme.colors.accent, fallbackColor: "bright_yellow"),
            text: vantuzRender._parseHex(theme.colors.text, fallbackColor: "white")
        )
        
    }
    
    func _getTitle (key_title: String) -> String {
        let rawTitle = self._getTitleRaw(key_title: key_title)
        let raw = key_title.split(separator: "_")
        let number = raw.count > 1 ? String(raw[1]) : "0"
        var name: String = ""
        if raw.count > 2 {
            if raw[0] == "disks" {
                name = String(raw[2])
            }
        }
        
        return rawTitle
            .replacing("{num}", with: number)
            .replacing("{name}", with: name)
    }
    
    static func _getTerminalSize() -> (rows: UInt16, cols: UInt16) {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            return (w.ws_row, w.ws_col)
        }
        return (24, 80)
    }
    
    func _getTitleRaw(key_title: String) -> String {
        switch key_title.split(separator: "_").first {
        case "os": return self.theme.strings.osTitle
        case "kernel": return self.theme.strings.kernelTitle
        case "machine": return self.theme.strings.machineTitle
        case "uptime": return self.theme.strings.uptimeTitle
        case "waketime": return self.theme.strings.waketimeTitle
        case "host": return self.theme.strings.hostTitle
        case "gpu": return self.theme.strings.gpuTitle
        case "display": return self.theme.strings.displayTitle
        case "disks": return self.theme.strings.disksTitle
        case "cpu": return self.theme.strings.cpuTitle
        case "mem": return self.theme.strings.memTitle
        case "swap": return self.theme.strings.swapTitle
            
        default: return "idk"
        }
    }
    func renderLine(index: Int, key_title: String, value: String) {
        // index will used sooner as logo render will be added.
        let title = _getTitle(key_title: key_title)
        let colorfulOutput = value
            .replacing("{{ ACCENT_COLOR }}", with: self.validColors.accent)
            .replacing("{{ TEXT }}", with: self.validColors.text)
        
        if self.isColorSupported {
            print("\(self.validColors.title)\(title): \(self.validColors.text)\(colorfulOutput)\(vantuzRender.reset)")
        } else {
            print("\(title): \(value)")
        }
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
    
    mutating func run() throws {
        let configInitializer = VantuzConfigInitializer()
        let activePaths = configInitializer.loadActivePaths()
        let configFile: vantuzConfig = configInitializer.loadConfig(from: activePaths.configURL)
        let themeFile: vantuzTheme = configInitializer.loadTheme(from: activePaths.themeURL)
        
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
        
        let vantuzRender = vantuzRender(theme: themeFile)
        for executed in modules {
            for result in executed {
                vantuzRender.renderLine(index: 0, key_title: result.keyId, value: result.value)
//                print("\(result.keyId): \(result.value)")
            }
        }
    }
}


