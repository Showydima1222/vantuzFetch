//
//  machine.swift
//  vantuzFetch
//
//  Created by showydima on 31.05.2026.
//

struct MachineModule: FetchableModule {
    let id: String = "machine"
    
    func run() -> [FetchResult] {
        return [FetchResult(keyId: self.id, value: sysctlString("hw.model") ?? "unknown")]
    }
}
