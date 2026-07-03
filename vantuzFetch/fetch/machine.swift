//
//  machine.swift
//  vantuzFetch
//
//  Created by showydima on 31.05.2026.
//

struct MachineModule: FetchableModule {
    let id: String = "machine"
    let isHeavy: Bool = false
    
    func run() -> [FetchResult] {
        let model = sysctlString("hw.model") ?? "unknown"
        let modeltype = sysctlString("hw.targettype").map { " (\($0))" } ?? ""
        return [FetchResult(keyId: self.id, value: "\(model)\(modeltype)")]
    }
}
