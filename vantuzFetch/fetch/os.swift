//
//  os.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//
import Foundation

class OSCodenameParser {
    private static let licenseRegex: NSRegularExpression? = {
            let pattern = #"macOS\s+(\w+)"#
            return try? NSRegularExpression(pattern: pattern)
        }()
    static let paths = [
        "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf"
    ]
    
    private static func getLicense(at path: String) -> String? {
        try? String(contentsOfFile: path, encoding: .utf8)
    }
    
    static func parseLicense() -> String? {
        guard let regex = licenseRegex else { return nil }
        return paths.lazy
            .compactMap { getLicense(at: $0) }
            .compactMap { content in
                let range = NSRange(content.startIndex..., in: content)
                guard let match = regex.firstMatch(in: content, range: range),
                      let versionRange = Range(match.range(at: 1), in: content) else { return nil }
                return String(content[versionRange])
            }
            .first
    }
    static func getOsCodename(_ version: Int) -> String? {
        OsCodenames.shared.getCodeName(version) ?? parseLicense()
    }
}

struct OSVersionModule: FetchableModule {
    let id: String = "os"
    var isFetched: Bool = false
    var results: [FetchResult] = []
    
    mutating func run() {
        let rawOsInfo = ProcessInfo.processInfo.operatingSystemVersion
        
        let major = rawOsInfo.majorVersion
        let minor = rawOsInfo.minorVersion
        let patch = rawOsInfo.patchVersion
        let fullVersion = patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
        
        let codename = OSCodenameParser.getOsCodename(major)
        let codenameSuffix = codename.map { " \($0)" } ?? ""
        self.results = [FetchResult(keyId: "os", value: "macOS \(fullVersion)\(codenameSuffix)")]
        self.isFetched = true
    }
}
