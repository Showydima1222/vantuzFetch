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
}

struct CpuInfo {
    let name: String
    let clusters: [CpuCluster]
    
    init() {
        self.name = CpuParser.getCpuName()
        self.clusters = CpuParser.getClusters(CpuName: self.name)
    }
    
    func getStringifiedClusters() -> String {
        var MaxBuffer: [String] = []
        var ThrottledBuffer: [String] = []
        for cluster in clusters {
            let isSystemThrottled = cluster.logicalCpuCount < cluster.logicalCpuCountMax || cluster.physicalCpuCount < cluster.physicalCpuCountMax
            let isLogicalEqPhysical = cluster.logicalCpuCount == cluster.physicalCpuCount
            let isLogicalEqPhysicalMax = cluster.logicalCpuCountMax == cluster.physicalCpuCountMax
            let isCoresDataFetched = cluster.logicalCpuCountMax > 0 && cluster.physicalCpuCountMax > 0
            
            // real physically existing cores
            let cpuCountMax: String = isLogicalEqPhysicalMax
                ? "\(cluster.physicalCpuCountMax)"
                : "\(cluster.physicalCpuCountMax) (\(cluster.logicalCpuCountMax))"
            let freq: String = cluster.coreFreq != nil ? " @ \(cluster.coreFreq!) mHz" : ""
            MaxBuffer.append("\(cluster.coreName): \(cpuCountMax)\(freq)")

            if isSystemThrottled {
                // if macOS disabled some cores
                let cpuCount: String = isLogicalEqPhysical
                    ? "\(cluster.physicalCpuCount)"
                    : "\(cluster.physicalCpuCount) (\(cluster.logicalCpuCount))"
                let freq: String = cluster.coreFreq != nil ? "@ \(cluster.coreFreq!) mHz" : ""
                ThrottledBuffer.append("\(cluster.coreName): \(cpuCount)\(freq)")
            }
            
        }
        if ThrottledBuffer.isEmpty {
            return "\(String(MaxBuffer.joined(separator: ", ")))"
        } else {
            return "Currently throttled: \(String(ThrottledBuffer.joined(separator: ", "))); Max: \(String(MaxBuffer.joined(separator: ", ")))"
        }
    }
}
