struct CpuFreq {
    let P_CORE_MAX_FREQ: Int
    let E_CORE_MAX_FREQ: Int
}

class CpuDatabase {
    private let cpuFreq: [String: CpuFreq] = [
        "apple m4": CpuFreq(P_CORE_MAX_FREQ: 4464, E_CORE_MAX_FREQ: 2892),
    ]
    private init() {}
    static let shared = CpuDatabase()
    func getCpuFreq(_ name: String) -> CpuFreq? {
        cpuFreq[name.lowercased()]
    }
}
