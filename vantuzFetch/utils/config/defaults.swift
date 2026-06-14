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
    [modules]
    # order matters 
    modules = ["os", "kernel", "machine", "host", "uptime", "cpu", "gpu", "mem", "disks"]
    # avaible modules:
    # os — macOS version
    # kernel – kernel version
    # machine — your machine model
    # uptime — uptime of system
    # host — host
    # gpu — list of all gpus (if there is egpu)
    # disks — list of all disks
    # cpu — information about cpu
    # mem — info about ram
    

    [diskConfig]
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
