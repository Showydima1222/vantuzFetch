//
//  memory.swift
//  vantuzFetch
//
//  Created by showydima on 03.04.2026.
//

import Foundation
import MachO

struct MemoryPressureModule: FetchableModule {
    let id: String = "mem_pressure"
    let isHeavy: Bool = false
       
    func run() -> [FetchResult] {
        let pressure = 100 - (sysctlInt("kern.memorystatus_level") ?? 0)
        
        return [FetchResult(keyId: self.id, value: "\(pressure)%", canBeSmartWrapped: true)]
    }
}
