//
//  memory.swift
//  vantuzFetch
//
//  Created by showydima on 03.04.2026.
//

import Foundation
import MachO

class MemoryParser {
    let stats: vm_statistics64?
    let isParsed: Bool
    init () {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: stats) / MemoryLayout<integer_t>.size)
        let hostPort = mach_host_self()
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }
        if result == KERN_SUCCESS {
            self.stats = stats
            self.isParsed = true
        } else {
            self.isParsed = false
            self.stats = nil
        }
        
    }
}

struct MemoryInfo {
    let total: UInt64
    let free: UInt64
    let active: UInt64
    let inactive: UInt64
    let wired: UInt64
    let speculative: UInt64
    let compressed: UInt64
    let external: UInt64
    let purgable: UInt64
    let swapped: UInt64
    var usedMemory : UInt64 {
        return total - (external + (free - speculative) )
    }
    init(stats: vm_statistics64, pageSize: UInt64) {
        func calcBytes(pageCount: UInt64) -> UInt64 {
            return pageCount * pageSize
        }
        self.total = UInt64(ProcessInfo.processInfo.physicalMemory)
        self.free = calcBytes(pageCount: UInt64(stats.free_count))
        self.active = calcBytes(pageCount: UInt64(stats.active_count))
        self.inactive = calcBytes(pageCount: UInt64(stats.inactive_count))
        self.wired = calcBytes(pageCount: UInt64(stats.wire_count))
        self.speculative = calcBytes(pageCount: UInt64(stats.speculative_count))
        self.compressed = calcBytes(pageCount: UInt64(stats.compressor_page_count))
        self.external = calcBytes(pageCount: UInt64(stats.external_page_count))
        self.purgable = calcBytes(pageCount: UInt64(stats.purgeable_count))
        self.swapped = calcBytes(pageCount: stats.swapped_count)
    }
}

class Memory {
    let info: MemoryInfo?
    let isParsed: Bool
    
    init() {
        let parser = MemoryParser()
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        self.isParsed = parser.isParsed
        if isParsed {
            self.info = MemoryInfo(
                stats: parser.stats!, pageSize: UInt64(pageSize)
            )
        } else { self.info = nil }

    }
}
