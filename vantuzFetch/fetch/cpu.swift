import Foundation

struct CpuCluster {
    let logicalCpuCount: Int
    let logicalCpuCountMax: Int
    let physicalCpuCount: Int
    let physicalCpuCountMax: Int
    let coreFreq: Int?
    let coreName: String
}

struct CpuStaticInfo: Codable {
    let PClusterCoreMaxFreq: Int
    let EClusterCoreMaxFreq: Int
}

struct CpuModule: FetchableModule {
    let id: String = "cpu"
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        let CPU_name = CpuParser.getCpuName()
        let CPU_clusters = CpuParser.getClusters(CpuName: CPU_name)
        if !CPU_clusters.isEmpty {
            let result: String = "\(CPU_name) (\(CpuParser.getStringifiedClusters(clusters: CPU_clusters)))"
            results = [FetchResult(keyId: self.id, value: result)]
        }
        return results
    }
}


class CpuParser {
    static func getCpuName() -> String{
        return sysctlString("machdep.cpu.brand_string") ?? "Unknown"
    }
    static func getCluster(_ clusterNumber: Int, cpu_name: String) -> CpuCluster {
        let _prefix = "hw.perflevel\(String(clusterNumber))"
        let name: String = sysctlString("\(_prefix).name") ?? "unknown"
        let physicalCoresMax: Int = sysctlInt("\(_prefix).physicalcpu_max") ?? 0
        let physicalCores: Int = sysctlInt("\(_prefix).physicalcpu") ?? 0
        let logicalCoresMax: Int = sysctlInt("\(_prefix).logicalcpu_max") ?? 0
        let logicalCores: Int = sysctlInt("\(_prefix).logicalcpu") ?? 0
        var coreFreq: Int? = nil
        let currentCpuInfo = CpuDatabase.shared.getCpuFreq(cpu_name)
        // cluster 0 = P, cluster 1 = E on Apple Silicon
        coreFreq = clusterNumber == 0 ? currentCpuInfo?.P_CORE_MAX_FREQ : currentCpuInfo?.E_CORE_MAX_FREQ
        return CpuCluster(logicalCpuCount: logicalCores, logicalCpuCountMax: logicalCoresMax, physicalCpuCount: physicalCores, physicalCpuCountMax: physicalCoresMax, coreFreq: coreFreq, coreName: name)
    }
    static func getClusters(CpuName: String) -> [CpuCluster] {
        let clustersLimit = 10 // limit to avoid infinity loop if sysctl gives wrong information
        var clusters: [CpuCluster] = []
        for i in 0..<clustersLimit {
            guard let _ = sysctlInt("hw.perflevel\(String(i)).logicalcpu") else {
                break
            }
            clusters.append(getCluster(i, cpu_name: CpuName))
        }
        return clusters
    }
    static func getStringifiedClusters(clusters: [CpuCluster]) -> String {
        var maxBuffer: [String] = []
        var throttledBuffer: [String] = []
        
        for cluster in clusters {
            func formatCpuCount(physical: Int, logical: Int) -> String {
                // if logical > physical; shows logical cores count in brackets
                return physical == logical ? "\(physical)" : "\(physical) (\(logical))"
            }
            let freqString = cluster.coreFreq.map { " @ \($0) MHz" } ?? ""
            let maxCores = formatCpuCount(physical: cluster.physicalCpuCountMax, logical: cluster.logicalCpuCountMax)
            maxBuffer.append("\(cluster.coreName): \(maxCores)\(freqString)")
            
            let areClustersDisabled = cluster.logicalCpuCount  <  cluster.logicalCpuCountMax
            || cluster.physicalCpuCount <  cluster.physicalCpuCountMax
            
            if areClustersDisabled {
                let activeCores = formatCpuCount(physical: cluster.physicalCpuCount,
                                                 logical: cluster.logicalCpuCount)
                throttledBuffer.append("\(cluster.coreName): \(activeCores)\(freqString)")
            }
        }
        if throttledBuffer.isEmpty {
                return maxBuffer.joined(separator: ", ")
            } else {
                return "Current Cores: \(throttledBuffer.joined(separator: ", ")); Should be in this machine: \(maxBuffer.joined(separator: ", "))"
            }
    }
}
