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
    var value: Int32 = 0
    var size = MemoryLayout<Int32>.size
    guard sysctlbyname(key, &value, &size, nil, 0) == 0 else { return nil }
    return Int(value)
}
