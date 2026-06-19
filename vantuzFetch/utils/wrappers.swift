import Foundation
import Darwin

func sysctlString(_ key: String) -> String? {
    var size: size_t = 0
    guard sysctlbyname(key, nil, &size, nil, 0) == 0 else { return nil }

    var buffer = [CChar](repeating: 0, count: size)
    guard sysctlbyname(key, &buffer, &size, nil, 0) == 0 else { return nil }

    return String(cString: buffer)
}

func sysctlInt(_ key: String) -> Int? {
    var size: size_t = 0 
    guard sysctlbyname(key, nil, &size, nil, 0) == 0 else { return nil }
    
    if size == MemoryLayout<Int32>.size {
        var value: Int32 = 0
        guard sysctlbyname(key, &value, &size, nil, 0) == 0 else { return nil }
        return Int(value)
    } else if size == MemoryLayout<Int64>.size {
        var value: Int64 = 0
        guard sysctlbyname(key, &value, &size, nil, 0) == 0 else { return nil }
        return Int(value)
    }
    
    return nil
}

func sysctlTime(_ key: String) -> Double? {
    var tv = timeval()
    var size = MemoryLayout<timeval>.size
    
    guard sysctlbyname(key, &tv, &size, nil, 0) == 0 else {
        return nil
    }

    return Double(tv.tv_sec) + Double(tv.tv_usec) / 1_000_000.0
}

func sysctlXusage(_ key: String) -> xsw_usage? {
    var xswUsage = xsw_usage()
    var size = MemoryLayout<xsw_usage>.size
    guard sysctlbyname(key, &xswUsage, &size, nil, 0) == 0 else {
        return nil
    }
    return xswUsage
}
