import Foundation
import MachO

var stats = vm_statistics64()
var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: stats) / MemoryLayout<integer_t>.size)

let hostPort = mach_host_self()
let result = withUnsafeMutablePointer(to: &stats) {
    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(hostPort, HOST_VM_INFO64, $0, &count)
    }
}

if result == KERN_SUCCESS {
    print(stats)
    var pageSize: vm_size_t = 0
    host_page_size(mach_host_self(), &pageSize)
    
    let swap = UInt64(stats.swapped_count) * UInt64(pageSize)
//    let swapGb = Double(swap) / pow(1024, 3)
    let external = UInt64(stats.external_page_count) * UInt64(pageSize)
//    let total_uncompressed_pages_in_compressor = UInt64(stats.total_uncompressed_pages_in_compressor) * UInt64(pageSize)
//    let total_uncompressed_pages_in_compressorGb = Double(total_uncompressed_pages_in_compressor) / pow(1024, 3)
        let free = UInt64(stats.free_count) * UInt64(pageSize)
//    let freeGb = Double(free) / pow(1024, 3)
        let active = UInt64(stats.active_count) * UInt64(pageSize)
//    let activeGb = Double(active) / pow(1024, 3)
        let inactive = UInt64(stats.inactive_count) * UInt64(pageSize)
//    let inactiveGb = Double(inactive) / pow(1024, 3)
    let wired = UInt64(stats.wire_count) * UInt64(pageSize)
//    let wiredGb = Double(wired) / pow(1024, 3)
    let speculative = UInt64(stats.speculative_count) * UInt64(pageSize)
    let speculativeGb = Double(speculative) / pow(1024, 3)
//    let purges = UInt64(stats.purges) * UInt64(pageSize)
//    let purgesGb = Double(purges) / pow(1024, 3)
//    print("really free: \(Double(free + speculative + inactive) / pow(1024,3))")
    let bytesTotal = 16632037376
    let ram = free + inactive + active + wired
    let pagesFree = free - speculative
    let used = UInt64(bytesTotal) - (pagesFree + external)
    
    }

