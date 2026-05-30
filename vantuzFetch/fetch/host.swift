//
//  host.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//

class OSHostParser {
    static func parseHostName(_ rawHostName: String) -> String {
        let name = rawHostName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return "localhost" }
        
        if name.localizedCaseInsensitiveHasSuffix(".local") { return String(name.dropLast(6)) }
        return name
}
}

struct OSHost: FetchableModule {
    let id: String = "host"
    var isFetched: Bool { get } = false
    var results: [FetchResult] { get } = []
    mutating func run() {
        self.results = [FetchResult(keyId: self.id, value: "\(OSHostParser.parseHostName(rawHostName: ProcessInfo.processInfo.hostName))")]
        self.isFetched = true
    }
}