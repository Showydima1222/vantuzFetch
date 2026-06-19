//
//  swap.swift
//  vantuzFetch
//
//  Created by showydima on 19.06.2026.
//
import Foundation

struct SwapModule: FetchableModule {
    let id: String = "swap"
    
    func run() -> [FetchResult] {
        let swap: xsw_usage? = sysctlXusage("vm.swapusage")
        if let swap: xsw_usage {
            let isEncrypted = swap.xsu_encrypted != 0 ? ", encrypted" : ""
            return([FetchResult(keyId: "swap", value: "\(UInt64(swap.xsu_used).autoCS()) (allocated: \(swap.xsu_total.autoCS()), free: \(swap.xsu_avail.autoCS())\(isEncrypted))")])
        }
        return [FetchResult(keyId: "spaw", value: "disabled")]
    }
}
