//
//  host.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//
import Foundation

class OSHostParser {
    static func parseHostName(_ rawHostName: String) -> String {
        let name = rawHostName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return "localhost" }
        
        if name.lowercased().hasSuffix(".local") { return String(name.dropLast(6)) }
        return name
}
}

struct OSHostModule: FetchableModule {
    let id: String = "host"
    var isFetched: Bool = false
    var results: [FetchResult] = []
    mutating func run() {
        self.results = [FetchResult(keyId: self.id, value: "\(OSHostParser.parseHostName(ProcessInfo.processInfo.hostName))")]
        self.isFetched = true
    }
}
