//
//  struct.swift
//  vantuzFetch
//
//  Created by showydima on 01.06.2026.
//
import TOML

struct vantuzConfigLocation: Codable {
    let config: String
    let theme: String
}

struct Modules: Codable {
    var modules: [String] = []
    var showTimePerformance: Bool = false
}

struct vantuzConfig: Codable {
    var modules: Modules = Modules()
    var diskConfig: DiskConfig = DiskConfig()
    var cpuConfig: CPUConfig = CPUConfig()
}

struct DiskConfig: Codable {
    var showPhysicalDiskNames: Bool = false
    var fastVolumeSizeCalculation: Bool = false
}

struct CPUConfig: Codable {
    var showCoresCount: Bool = true
    var showClusters: Bool = true
    var showClusterNames: Bool = true
    var showClusterCache: Bool = true
}

struct vantuzTheme: Codable {
    
}
