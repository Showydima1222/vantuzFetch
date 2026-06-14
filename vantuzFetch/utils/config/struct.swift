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
}

struct vantuzConfig: Codable {
    var modules: Modules = Modules()
    var diskConfig: DiskConfig = DiskConfig()
}

struct DiskConfig: Codable {
    var showPhysicalDiskNames: Bool = false
    var fastVolumeSizeCalculation: Bool = false
}

struct vantuzTheme: Codable {
    
}
