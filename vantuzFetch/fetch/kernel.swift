//
//  kernel.swift
//  vantuzFetch
//
//  Created by showydima on 14.06.2026.
//

struct KernelModule: FetchableModule {
    let id: String = "kernel"
    
    var showBuildDate: Bool
    
    func run() -> [FetchResult] {
        let kernelVersion: String? = sysctlString("kern.version")
        if let kernelVersion {
            var kernelVersionString:String = kernelVersion.split(separator: ";").first.map(String.init) ?? ""
            
            if !self.showBuildDate {
                kernelVersionString = kernelVersionString.split(separator: ":").first.map(String.init) ?? ""
            }
            
            return [FetchResult(keyId: "kernel", value: kernelVersionString, canBeSmartWrapped: true)]
        }
        return []
    }
}
