//
//  os.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//
import Foundation

class OSCodenameParser {
    private static let licenseRegex: NSRegularExpression? = {
        let pattern = #"macOS\s+(.+?)(?=\s+(?:software|license|agreement|pre-release|seed))"#
        return try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
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
                
                let codename = content[versionRange].trimmingCharacters(in: .whitespacesAndNewlines)
                return codename.isEmpty ? nil : String(codename)
            }
            .first
    }
    
    static func getOsCodename(_ version: Int) -> String? {
        OsCodenames.shared.getCodeName(version) ?? parseLicense()
    }
}
struct OSVersionModule: FetchableModule {
    let id: String = "os"
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        let rawOsInfo = ProcessInfo.processInfo.operatingSystemVersion
        let versionRaw = sysctlString("kern.osversion") ?? "unknown?"
        
        let major = rawOsInfo.majorVersion
        let minor = rawOsInfo.minorVersion
        let patch = rawOsInfo.patchVersion
        let fullVersion = patch == 0 ? "\(major).\(minor)" : "\(major).\(minor).\(patch)"
        
        let codename = OSCodenameParser.getOsCodename(major)
        let codenameSuffix = codename.map { " \($0)" } ?? ""
        results = [FetchResult(keyId: "os", value: "macOS \(fullVersion) (\(versionRaw))\(codenameSuffix)", canBeSmartWrapped: true)]
        return results
    }
}
