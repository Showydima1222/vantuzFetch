//
//  extentions.swift
//  vantuzFetch
//
//  Created by showydima on 05.04.2026.
//
import Foundation

extension BinaryInteger {
    func asKiB() -> Double { Double(self) / 1024 }
    func asKB()  -> Double { Double(self) / 1000 }

    func asMiB() -> Double { Double(self) / 1024 / 1024 }
    func asMB()  -> Double { Double(self) / 1000 / 1000 }

    func asGiB() -> Double { Double(self) / 1024 / 1024 / 1024 }
    func asGB()  -> Double { Double(self) / 1000 / 1000 / 1000 }
}

extension BinaryFloatingPoint {
    func asKiB() -> Double { Double(self) / 1024 }
    func asKB()  -> Double { Double(self) / 1000 }

    func asMiB() -> Double { Double(self) / 1024 / 1024 }
    func asMB()  -> Double { Double(self) / 1000 / 1000 }

    func asGiB() -> Double { Double(self) / 1024 / 1024 / 1024 }
    func asGB()  -> Double { Double(self) / 1000 / 1000 / 1000 }
    
    func asFormattedString(_ numbersCount: Int = 2) -> String { Double(self).formatted(.number.precision(.fractionLength(0...numbersCount))) }
}
