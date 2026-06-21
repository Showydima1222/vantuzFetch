import Foundation

struct CpuCluster {
    let logicalCpuCount: Int
    let logicalCpuCountMax: Int
    let physicalCpuCount: Int
    let physicalCpuCountMax: Int
    let coreFreq: Int?
    let coreName: String?
    let firstLevelCache: Int
    let secondLevelCache: Int
}

struct CpuStaticInfo: Codable {
    let PClusterCoreMaxFreq: Int
    let EClusterCoreMaxFreq: Int
}

struct CpuModule: FetchableModule {
    let id: String = "cpu"
    
    var CpuConfig: CPUConfig
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        let CPU_name = CpuParser.getCpuName()
        
        let result: String
        if CpuConfig.showCoresCount {
            if CpuConfig.showClusters {
                let CPU_clusters = CpuParser.getClusters(cpuName: CPU_name, config: CpuConfig)
                if !CPU_clusters.isEmpty {
                    result = "\(CPU_name) (\(CpuParser.getStringifiedClusters(clusters: CPU_clusters)))"
                } else { result = "\(CPU_name) No clusters recognized"}
            } else { var coresCount: String = CpuParser.getCoresCount(); coresCount = coresCount != "" ? " (\(coresCount))" : ""; result = "\(CPU_name)\(coresCount)" }
        } else { result = CPU_name }
        
        results = [FetchResult(keyId: self.id, value: result)]
        return results
    }
}


class CpuParser {
    static func getCpuName() -> String{
        return sysctlString("machdep.cpu.brand_string") ?? "Unknown"
    }
    
    static func getCoresCount() -> String {
        let physicalCores    = sysctlInt("hw.physicalcpu") ?? 0
        let logicalCores     = sysctlInt("hw.logicalcpu") ?? 0
        if physicalCores == logicalCores { return "\(physicalCores)" }
        return "\(physicalCores) (\(logicalCores))"
    }
    
    static func formatCpuCount(physical: Int, logical: Int) -> String {
        // if logical > physical; shows logical cores count in brackets
        return physical == logical ? "\(physical)" : "\(physical) (\(logical))"
    }
    
    static func getCluster(_ clusterNumber: Int, cpu_name: String, config: CPUConfig) -> CpuCluster {
        let _prefix = "hw.perflevel\(String(clusterNumber))"
        var name: String? = nil
        if config.showClusterNames {
            name = sysctlString("\(_prefix).name") ?? "unknown"
        }
        var physicalCoresMax = 0
        var physicalCores = 0
        var logicalCoresMax = 0
        var logicalCores = 0
        
        var firstLevelCache = 0
        var secondLevelCache = 0
        
        if config.showCoresCount {
            physicalCoresMax = sysctlInt("\(_prefix).physicalcpu_max") ?? 0
            physicalCores    = sysctlInt("\(_prefix).physicalcpu") ?? 0
            logicalCoresMax  = sysctlInt("\(_prefix).logicalcpu_max") ?? 0
            logicalCores     = sysctlInt("\(_prefix).logicalcpu") ?? 0
        }
        
        if config.showClusterCache && config.showClusters {
            let l1i = sysctlInt("\(_prefix).l1icachesize") ?? 0
            let l1d = sysctlInt("\(_prefix).l1dcachesize") ?? 0
            firstLevelCache = l1i + l1d
            
            secondLevelCache = sysctlInt("\(_prefix).l2cachesize") ?? 0
        }
        
        var coreFreq: Int? = nil
        var currentCpuInfo:CpuFreq?  = nil
        if (config.showClusters && config.showCoresCount) {
            currentCpuInfo = CpuDatabase.shared.getCpuFreq(cpu_name)
        }
        
        // cluster 0 = P, cluster 1 = E on Apple Silicon
        coreFreq = clusterNumber == 0 ? currentCpuInfo?.P_CORE_MAX_FREQ : currentCpuInfo?.E_CORE_MAX_FREQ
        
        return CpuCluster(logicalCpuCount: logicalCores, logicalCpuCountMax: logicalCoresMax, physicalCpuCount: physicalCores, physicalCpuCountMax: physicalCoresMax, coreFreq: coreFreq, coreName: name, firstLevelCache: firstLevelCache, secondLevelCache: secondLevelCache)
    }
    static func getClusters(cpuName: String, config:CPUConfig) -> [CpuCluster] {
        let clustersLimit = 10 // limit to avoid infinity loop if sysctl gives wrong information
        var clusters: [CpuCluster] = []
        for i in 0..<clustersLimit {
            guard let _ = sysctlInt("hw.perflevel\(String(i)).logicalcpu") else {
                break
            }
            clusters.append(getCluster(i, cpu_name: cpuName, config: config))
        }
        return clusters
    }
    
    static func getStringifiedClusters(clusters: [CpuCluster]) -> String {
        var maxBuffer: [String] = []
        var throttledBuffer: [String] = []
        
        for cluster in clusters {

            let freqString = cluster.coreFreq.map { " @ \($0)MHz" } ?? ""
            
            let secondCacheLevelString: String = cluster.secondLevelCache != 0 ?
            "L2: \(cluster.secondLevelCache.autoCS())" : ""
            let firstCacheLevelString: String = cluster.firstLevelCache != 0 ?
            " L1: \(cluster.firstLevelCache.autoCS())\(cluster.secondLevelCache != 0 ? ", " : "")" : ""
            let cacheString = "\(firstCacheLevelString)\(secondCacheLevelString)"
            let maxCores = formatCpuCount(physical: cluster.physicalCpuCountMax, logical: cluster.logicalCpuCountMax)
            var name = cluster.coreName == nil ? "" : " \(cluster.coreName!)"
            maxBuffer.append("\(maxCores)\(name)\(freqString)\(cacheString)")
            
            let areClustersDisabled = cluster.logicalCpuCount  <  cluster.logicalCpuCountMax
            || cluster.physicalCpuCount <  cluster.physicalCpuCountMax
            
            if areClustersDisabled {
                let activeCores = formatCpuCount(physical: cluster.physicalCpuCount,
                                                 logical: cluster.logicalCpuCount)
                name = "\(name): "
                throttledBuffer.append("\(name)\(activeCores)\(freqString)")
            }
        }
        if throttledBuffer.isEmpty {
                return maxBuffer.joined(separator: " || ")
        }
        return "Current Cores: \(throttledBuffer.joined(separator: ", ")); Should be in this machine: \(maxBuffer.joined(separator: ", "))"
    }
}
