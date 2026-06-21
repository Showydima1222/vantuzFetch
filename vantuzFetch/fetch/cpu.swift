import Foundation

struct CpuCluster {
    let coreCount: Int
    let coreFreq: Int?
    let coreName: String?
    let l1Cache: Int
    let l2Cache: Int
}

struct CpuStaticInfo: Codable {
    let pClusterCoreMaxFreq: Int
    let eClusterCoreMaxFreq: Int
}

struct CpuModule: FetchableModule {
    let id: String = "cpu"
    var cpuConfig: CPUConfig
    
    func run() -> [FetchResult] {
        let cpuName = CpuParser.getCpuName()
        
        guard cpuConfig.showCoresCount else {
            return [FetchResult(keyId: self.id, value: cpuName)]
        }
        
        let result: String
        if cpuConfig.showClusters {
            let cpuClusters = CpuParser.getClusters(cpuName: cpuName, config: cpuConfig)
            result = cpuClusters.isEmpty
                ? "\(cpuName) No clusters recognized"
                : "\(cpuName) (\(CpuParser.getStringifiedClusters(clusters: cpuClusters)))"
        } else {
            let coresCount = CpuParser.getCoresCount()
            result = coresCount.isEmpty ? cpuName : "\(cpuName) (\(coresCount))"
        }
        
        return [FetchResult(keyId: self.id, value: result)]
    }
}

class CpuParser {
    static func getCpuName() -> String {
        return sysctlString("machdep.cpu.brand_string") ?? "Unknown"
    }
    
    static func getCoresCount() -> String {
        guard let cores = sysctlInt("hw.physicalcpu") else { return "" }
        return "\(cores)"
    }
    
    static func getCluster(_ clusterNumber: Int, cpuName: String, config: CPUConfig) -> CpuCluster {
        let prefix = "hw.perflevel\(clusterNumber)"
        
        let name = config.showClusterNames ? sysctlString("\(prefix).name") : nil
        
        var coreCount = 0
        if config.showCoresCount {
            coreCount = sysctlInt("\(prefix).physicalcpu") ?? 0
        }
        
        var l1Cache = 0
        var l2Cache = 0
        if config.showClusterCache && config.showClusters {
            let l1i = sysctlInt("\(prefix).l1icachesize") ?? 0
            let l1d = sysctlInt("\(prefix).l1dcachesize") ?? 0
            l1Cache = l1i + l1d
            l2Cache = sysctlInt("\(prefix).l2cachesize") ?? 0
        }
        
        var coreFreq: Int? = nil
        if config.showClusters && config.showCoresCount {
            let currentCpuInfo = CpuDatabase.shared.getCpuFreq(cpuName)
            // cluster 0 = Performance cores, cluster 1 = Efficiency cores
            coreFreq = (clusterNumber == 0) ? currentCpuInfo?.P_CORE_MAX_FREQ : currentCpuInfo?.E_CORE_MAX_FREQ
        }
        
        return CpuCluster(
            coreCount: coreCount,
            coreFreq: coreFreq,
            coreName: name,
            l1Cache: l1Cache,
            l2Cache: l2Cache
        )
    }
    
    static func getClusters(cpuName: String, config: CPUConfig) -> [CpuCluster] {
        let clustersLimit = 4 // На текущих чипах Apple более 2-4 перф-уровней не существует
        var clusters: [CpuCluster] = []
        
        for i in 0..<clustersLimit {
            guard sysctlInt("hw.perflevel\(i).physicalcpu") != nil else { break }
            clusters.append(getCluster(i, cpuName: cpuName, config: config))
        }
        return clusters
    }
    
    static func getStringifiedClusters(clusters: [CpuCluster]) -> String {
        return clusters.map { cluster in
            let nameStr = cluster.coreName.map { " \($0)" } ?? ""
            let freqStr = cluster.coreFreq.map { " @ \($0)MHz" } ?? ""
            
            var cacheParts: [String] = []
            if cluster.l1Cache > 0 { cacheParts.append("L1: \(cluster.l1Cache.autoCS())") }
            if cluster.l2Cache > 0 { cacheParts.append("L2: \(cluster.l2Cache.autoCS())") }
            let cacheStr = cacheParts.isEmpty ? "" : " " + cacheParts.joined(separator: ", ")
            
            return "\(cluster.coreCount)\(nameStr)\(freqStr)\(cacheStr)"
        }.joined(separator: " || ")
    }
}
