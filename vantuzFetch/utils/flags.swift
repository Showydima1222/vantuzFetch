//
//  flags.swift
//  vantuzFetch
//
//  Created by showydima on 22.06.2026.
//
import ArgumentParser

extension VantuzFetch {
    struct FlagOptions: ParsableArguments {
        @Flag(name: .customLong("physical-disk-names"), inversion: .prefixedNo, help: "Show or hide physical names of disks.")
        var showPhysicalDiskNames: Bool?

        @Flag(name: .customLong("fast-disk-size-calc"), inversion: .prefixedNo, help: "Enable fast disk size calculation (disables calculation of deletable cache).")
        var fastDiskSizeCalc: Bool?

        @Flag(name: [.customShort("a"), .customLong("all")], help: "Show all modules")
        var showAllModules = false

        @Flag(name: .customLong("time"), inversion: .prefixedNo, help: "Measure time of fetching.")
        var measureTime: Bool?
    }
}
