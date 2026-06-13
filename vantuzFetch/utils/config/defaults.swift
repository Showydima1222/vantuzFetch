//
//  defaults.swift
//  vantuzFetch
//
//  Created by showydima on 14.06.2026.
//


import Foundation

enum DefaultTemplates {
    
    static let globalToml = """
    using_config = "default"
    using_theme = "default"
    """
    
    static let configToml = """
    title = "vantuz!"
    showPhysicalDiskNames = false
    [modules]
    os = true
    cpu = true
    memory = true
    disks = true
    uptime = true
    

    [disks_settings]
    showPhysicalDiskNames = false
    """
    
    static let themeToml = """
    [colors]
    title = "magenta"
    accent = "cyan"
    text = "white"

    [layout]
    padding_left = 2
    separator = " -> "
    """
}
