//
//  kernel.swift
//  vantuzFetch
//
//  Created by showydima on 14.06.2026.
//

struct KernelModule: FetchableModule {
    let id: String = "kernel"
    
    func run() -> [FetchResult] {
        let kernelVersion: String? = sysctlString("kern.version")
        if var kernelVersion {
            kernelVersion = kernelVersion.split(separator: ";").first.map(String.init) ?? ""
            return [FetchResult(keyId: "kernel", value: kernelVersion)]
        }
        return []
    }
}
