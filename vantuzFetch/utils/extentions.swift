//
//  extentions.swift
//  vantuzFetch
//
//  Created by showydima on 05.04.2026.
//
import Foundation

extension BinaryFloatingPoint {
    func asKiB() -> Double { Double(self) / 1024 }
    func asKB()  -> Double { Double(self) / 1000 }

    func asMiB() -> Double { Double(self) / 1024 / 1024 }
    func asMB()  -> Double { Double(self) / 1000 / 1000 }

    func asGiB() -> Double { Double(self) / 1024 / 1024 / 1024 }
    func asGB()  -> Double { Double(self) / 1000 / 1000 / 1000 }
    
    func asTiB() -> Double { Double(self) / 1024 / 1024 / 1024 / 1024 }
    func asTB()  -> Double { Double(self) / 1000 / 1000 / 1000 / 1000 }
    
    func asFormattedString(_ numbersCount: Int = 2) -> String {
        Double(self).formatted(
            .number.precision(.fractionLength(0...numbersCount))
            .grouping(.never)
        ).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension BinaryInteger {
    private var asDouble: Double { Double(self) }

    func asKiB() -> Double { asDouble.asKiB() }
    func asKB()  -> Double { asDouble.asKB() }
    func asMiB() -> Double { asDouble.asMiB() }
    func asMB()  -> Double { asDouble.asMB() }
    func asGiB() -> Double { asDouble.asGiB() }
    func asGB()  -> Double { asDouble.asGB() }
    func asTiB() -> Double { asDouble.asTiB() }
    func asTB()  -> Double { asDouble.asTB() }

    func autoSI() -> String {
        let bytes = asDouble
        if bytes < 1000 { return "\(self) B" }
        else if bytes < 1000 * 1000 { return "\(bytes.asKB().asFormattedString()) KB" }
        else if bytes < 1000 * 1000 * 1000 { return "\(bytes.asMB().asFormattedString()) MB" }
        else if bytes < 1000 * 1000 * 1000 * 1000 { return "\(bytes.asGB().asFormattedString()) GB" }
        else { return "\(bytes.asTB().asFormattedString()) TB" }
    }

    func autoCS() -> String {
        let bytes = asDouble
        if bytes < 1024 { return "\(self) B" }
        else if bytes < 1024 * 1024 { return "\(bytes.asKiB().asFormattedString()) KiB" }
        else if bytes < 1024 * 1024 * 1024 { return "\(bytes.asMiB().asFormattedString()) MiB" }
        else if bytes < 1024 * 1024 * 1024 * 1024 { return "\(bytes.asGiB().asFormattedString()) GiB" }
        else { return "\(bytes.asTiB().asFormattedString()) TiB" }
    }
}
