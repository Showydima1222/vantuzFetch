//
//  struct.swift
//  vantuzFetch
//
//  Created by showydima on 01.06.2026.
//
import TOML

struct vantuzConfigLocation: Codable {
    var config: String
    var theme: String

    enum CodingKeys: String, CodingKey {
        case config
        case theme
    }

    init(config: String = "", theme: String = "") {
        self.config = config
        self.theme = theme
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.config = try container.decodeIfPresent(String.self, forKey: .config) ?? ""
        self.theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? ""
    }
}

struct Modules: Codable {
    var modules: [String]
    var showTimePerformance: Bool

    enum CodingKeys: String, CodingKey {
        case modules
        case showTimePerformance
    }

    init(modules: [String] = [], showTimePerformance: Bool = false) {
        self.modules = modules
        self.showTimePerformance = showTimePerformance
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modules = try container.decodeIfPresent([String].self, forKey: .modules) ?? []
        self.showTimePerformance = try container.decodeIfPresent(Bool.self, forKey: .showTimePerformance) ?? false
    }
}
struct DiskConfig: Codable {
    var showPhysicalDiskNames: Bool
    var fastVolumeSizeCalculation: Bool

    enum CodingKeys: String, CodingKey {
        case showPhysicalDiskNames
        case fastVolumeSizeCalculation
    }

    init(showPhysicalDiskNames: Bool = false, fastVolumeSizeCalculation: Bool = false) {
        self.showPhysicalDiskNames = showPhysicalDiskNames
        self.fastVolumeSizeCalculation = fastVolumeSizeCalculation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.showPhysicalDiskNames = try container.decodeIfPresent(Bool.self, forKey: .showPhysicalDiskNames) ?? false
        self.fastVolumeSizeCalculation = try container.decodeIfPresent(Bool.self, forKey: .fastVolumeSizeCalculation) ?? false
    }
}

struct KernelConfig: Codable {
    var showBuildDate: Bool

    enum CodingKeys: String, CodingKey {
        case showBuildDate
    }

    init(showBuildDate: Bool = false) {
        self.showBuildDate = showBuildDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.showBuildDate = try container.decodeIfPresent(Bool.self, forKey: .showBuildDate) ?? false
    }
}

struct CPUConfig: Codable {
    var showCoresCount: Bool
    var showClusters: Bool
    var showClusterNames: Bool
    var showClusterCache: Bool

    enum CodingKeys: String, CodingKey {
        case showCoresCount
        case showClusters
        case showClusterNames
        case showClusterCache
    }

    init(showCoresCount: Bool = true, showClusters: Bool = true, showClusterNames: Bool = true, showClusterCache: Bool = true) {
        self.showCoresCount = showCoresCount
        self.showClusters = showClusters
        self.showClusterNames = showClusterNames
        self.showClusterCache = showClusterCache
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.showCoresCount = try container.decodeIfPresent(Bool.self, forKey: .showCoresCount) ?? true
        self.showClusters = try container.decodeIfPresent(Bool.self, forKey: .showClusters) ?? true
        self.showClusterNames = try container.decodeIfPresent(Bool.self, forKey: .showClusterNames) ?? true
        self.showClusterCache = try container.decodeIfPresent(Bool.self, forKey: .showClusterCache) ?? true
    }
}

struct vantuzConfig: Codable {
    var modules: Modules
    var diskConfig: DiskConfig
    var cpuConfig: CPUConfig
    var kernelConfig: KernelConfig

    enum CodingKeys: String, CodingKey {
        case modules
        case diskConfig
        case cpuConfig
        case kernelConfig
    }

    init(modules: Modules = Modules(), diskConfig: DiskConfig = DiskConfig(), cpuConfig: CPUConfig = CPUConfig(), kernelConfig: KernelConfig = KernelConfig()) {
        self.modules = modules
        self.diskConfig = diskConfig
        self.cpuConfig = cpuConfig
        self.kernelConfig = kernelConfig
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modules = try container.decodeIfPresent(Modules.self, forKey: .modules) ?? Modules()
        self.diskConfig = try container.decodeIfPresent(DiskConfig.self, forKey: .diskConfig) ?? DiskConfig()
        self.cpuConfig = try container.decodeIfPresent(CPUConfig.self, forKey: .cpuConfig) ?? CPUConfig()
        self.kernelConfig = try container.decodeIfPresent(KernelConfig.self, forKey: .kernelConfig) ?? KernelConfig()
    }
}

struct VantuzThemeTextConfig: Codable {
    var wrapPolicy: String

    enum CodingKeys: String, CodingKey {
        case wrapPolicy
    }

    init(wrapPolicy: String = "smart") {
        self.wrapPolicy = wrapPolicy
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.wrapPolicy = try container.decodeIfPresent(String.self, forKey: .wrapPolicy) ?? "smart"
    }
}

struct vantuzColors: Codable {
    var title: String
    var accent: String
    var text: String

    enum CodingKeys: String, CodingKey {
        case title
        case accent
        case text
    }

    init(title: String = "", accent: String = "", text: String = "") {
        self.title = title
        self.accent = accent
        self.text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.accent = try container.decodeIfPresent(String.self, forKey: .accent) ?? ""
        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
    }
}

struct vantuzStrings: Codable {
    var osTitle: String
    var kernelTitle: String
    var machineTitle: String
    var uptimeTitle: String
    var waketimeTitle: String
    var terminalTitle: String
    var shellTitle: String
    var hostTitle: String
    var gpuTitle: String
    var displayTitle: String
    var disksTitle: String
    var cpuTitle: String
    var memTitle: String
    var memPressureTitle: String
    var swapTitle: String

    enum CodingKeys: String, CodingKey {
        case osTitle
        case kernelTitle
        case machineTitle
        case uptimeTitle
        case waketimeTitle
        case terminalTitle
        case shellTitle
        case hostTitle
        case gpuTitle
        case displayTitle
        case disksTitle
        case cpuTitle
        case memTitle
        case memPressureTitle
        case swapTitle
    }

    init(
        osTitle: String = DefaultStrings.osTitle,
        kernelTitle: String = DefaultStrings.kernelTitle,
        machineTitle: String = DefaultStrings.machineTitle,
        uptimeTitle: String = DefaultStrings.uptimeTitle,
        waketimeTitle: String = DefaultStrings.waketimeTitle,
        terminalTitle: String = DefaultStrings.terminalTitle,
        shellTitle: String = DefaultStrings.shellTitle,
        hostTitle: String = DefaultStrings.hostTitle,
        gpuTitle: String = DefaultStrings.gpuTitle,
        displayTitle: String = DefaultStrings.displayTitle,
        disksTitle: String = DefaultStrings.disksTitle,
        cpuTitle: String = DefaultStrings.cpuTitle,
        memTitle: String = DefaultStrings.memTitle,
        memPressureTitle: String = DefaultStrings.memPressureTitle,
        swapTitle: String = DefaultStrings.swapTitle,
    ) {
        self.osTitle = osTitle
        self.kernelTitle = kernelTitle
        self.machineTitle = machineTitle
        self.uptimeTitle = uptimeTitle
        self.waketimeTitle = waketimeTitle
        self.terminalTitle = terminalTitle
        self.shellTitle = shellTitle
        self.hostTitle = hostTitle
        self.gpuTitle = gpuTitle
        self.displayTitle = displayTitle
        self.disksTitle = disksTitle
        self.cpuTitle = cpuTitle
        self.memTitle = memTitle
        self.memPressureTitle = memPressureTitle
        self.swapTitle = swapTitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.osTitle = try container.decodeIfPresent(String.self, forKey: .osTitle) ?? DefaultStrings.osTitle
        self.kernelTitle = try container.decodeIfPresent(String.self, forKey: .kernelTitle) ?? DefaultStrings.kernelTitle
        self.machineTitle = try container.decodeIfPresent(String.self, forKey: .machineTitle) ?? DefaultStrings.machineTitle
        self.uptimeTitle = try container.decodeIfPresent(String.self, forKey: .uptimeTitle) ?? DefaultStrings.uptimeTitle
        self.waketimeTitle = try container.decodeIfPresent(String.self, forKey: .waketimeTitle) ?? DefaultStrings.waketimeTitle
        self.terminalTitle = try container.decodeIfPresent(String.self, forKey: .terminalTitle) ?? DefaultStrings.terminalTitle
        self.shellTitle = try container.decodeIfPresent(String.self, forKey: .shellTitle) ?? DefaultStrings.shellTitle
        self.hostTitle = try container.decodeIfPresent(String.self, forKey: .hostTitle) ?? DefaultStrings.hostTitle
        self.gpuTitle = try container.decodeIfPresent(String.self, forKey: .gpuTitle) ?? DefaultStrings.gpuTitle
        self.displayTitle = try container.decodeIfPresent(String.self, forKey: .displayTitle) ?? DefaultStrings.displayTitle
        self.disksTitle = try container.decodeIfPresent(String.self, forKey: .disksTitle) ?? DefaultStrings.disksTitle
        self.cpuTitle = try container.decodeIfPresent(String.self, forKey: .cpuTitle) ?? DefaultStrings.cpuTitle
        self.memTitle = try container.decodeIfPresent(String.self, forKey: .memTitle) ?? DefaultStrings.memTitle
        self.memPressureTitle = try container.decodeIfPresent(String.self, forKey: .memPressureTitle) ?? DefaultStrings.memPressureTitle
        self.swapTitle = try container.decodeIfPresent(String.self, forKey: .swapTitle) ?? DefaultStrings.swapTitle
    }
}

struct vantuzTheme: Codable {
    var colors: vantuzColors
    var strings: vantuzStrings
    var text: VantuzThemeTextConfig

    enum CodingKeys: String, CodingKey {
        case colors
        case strings
        case text
    }

    init(
        colors: vantuzColors = vantuzColors(),
        strings: vantuzStrings = vantuzStrings(),
        text: VantuzThemeTextConfig = VantuzThemeTextConfig()
    ) {
        self.colors = colors
        self.strings = strings
        self.text = text
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.colors = try container.decodeIfPresent(vantuzColors.self, forKey: .colors) ?? vantuzColors()
        self.strings = try container.decodeIfPresent(vantuzStrings.self, forKey: .strings) ?? vantuzStrings()
        self.text = try container.decodeIfPresent(VantuzThemeTextConfig.self, forKey: .text) ?? VantuzThemeTextConfig()
    }
}
