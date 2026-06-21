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
    modules = ["os", "kernel", "machine", "host", "uptime", "cpu", "gpu", "mem", "swap","disks"]
    
    # avaible modules:
    # all — not a module but if "all" in this list, fetch will be forced to show all modules.
    #
    # os — macOS version
    # kernel – kernel version
    # shell — shell
    # terminal — terminal
    # machine — your machine model
    # host — host
    # uptime — uptime of system (time from last boot)
    # waketime — waketime (time from last sleep)
    # gpu — list of all gpus (if there is egpu)
    # cpu — information about cpu
    # mem — info about ram
    # swap - info about swap
    # disks — list of all disks
    
    # Shows time of fetching for every module
    showTimePerformance = false
    

    [diskConfig]
    # config for disks module
    showPhysicalDiskNames = false
    
    # Fast will show real physically used space. Disabling fast will dont calculate space that macOS caching in this disk (real avaible space)
    fastVolumeSizeCalculation = false
    
    [cpuConfig]
    # Config for cpu module
    
    showCoresCount = true
    
    # if enabled showCoresCount 
    showClusters = true
    
    #if enabled showClusters
    showClusterNames = true
    
    # if enabled ShowClusters
    showClusterCache = true

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
