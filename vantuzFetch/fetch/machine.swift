//
//  machine.swift
//  vantuzFetch
//
//  Created by showydima on 31.05.2026.
//

struct MachineModule: FetchableModule {
    let id: String = "machine"
    var isFetched: Bool = false
    var results: [FetchResult] = []
    mutating func run() {
        self.results = [FetchResult(keyId: self.id, value: sysctlString("hw.model") ?? "unknown")]
        self.isFetched = true
    }
}