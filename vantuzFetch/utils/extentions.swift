//
//  extentions.swift
//  vantuzFetch
//
//  Created by showydima on 05.04.2026.
//

extension UInt64 {
    func asKB() -> Double {
        return Double(self) / 1024
    }

    func asMB() -> Double {
        return Double(self) / 1024 / 1024
    }

    func asGB() -> Double {
        return Double(self) / 1024 / 1024 / 1024
    }
}

extension Double {
    func asKB() -> Double {
        return Double(self) / 1024
    }

    func asMB() -> Double {
        return Double(self) / 1024 / 1024
    }

    func asGB() -> Double {
        return Double(self) / 1024 / 1024 / 1024
    }
}
