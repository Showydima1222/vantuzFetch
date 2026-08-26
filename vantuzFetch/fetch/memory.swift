//
//  memory.swift
//  vantuzFetch
//
//  Created by showydima on 03.04.2026.
//

import Foundation
import MachO

struct MemoryModule: FetchableModule {
    let id: String = "mem"
    let isHeavy: Bool = false
       
    func run() -> [FetchResult] {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let hostPort = mach_host_self()
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return [] }
        
        var pageSize: vm_size_t = 0
        host_page_size(hostPort, &pageSize)
        let uPageSize = UInt64(pageSize)
        
        let total = UInt64(ProcessInfo.processInfo.physicalMemory)
        let free = UInt64(stats.free_count) * uPageSize
        let speculative = UInt64(stats.speculative_count) * uPageSize
        let external = UInt64(stats.external_page_count) * uPageSize
        
        let usedMemory = total - (external + (free - speculative))
        
        return [FetchResult(keyId: self.id, value: "\(total.autoCS()), \(usedMemory.autoCS()) used", canBeSmartWrapped: true)]
    }
}
