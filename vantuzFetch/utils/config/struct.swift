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

struct vantuzConfig: Codable {
    let showPhysicalDiskNames: Bool
}

struct vantuzTheme: Codable {
    
}
