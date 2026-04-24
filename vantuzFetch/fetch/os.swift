import Foundation

class OsLicenseParser {
    static let paths = [
        "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf"
    ]
    
    private static func getLicense(at path: String) -> String? {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        guard let data = try? String(data: Data(contentsOf: URL(fileURLWithPath: path)), encoding: .utf8) else { return nil }
        return data
    }
    static func parseLICENSE() -> String? {
        let pattern = "macOS\\s+(\\w+)"
        let regex = try! NSRegularExpression(pattern: pattern)
        
        for path in paths {
            guard let content = getLicense(at: path) else { continue }
            
            for line in content.components(separatedBy: .newlines) {
                let range = NSRange(line.startIndex..., in: line)
                
                if let match = regex.firstMatch(in: line, range: range),
                   let versionRange = Range(match.range(at: 1), in: line) {
                    return String(line[versionRange])
                }
            }
        }
        
        return nil
    }
}

class OsParser {
    
    static func parseHostName(rawHostName: String) -> String {
        // deletes .local from hostName
        if rawHostName.lowercased().hasSuffix(".local") { return String(rawHostName.dropLast(".local".count)) }
        else { return String(rawHostName.isEmpty ? "localhost" : rawHostName) }
    }
    static func getOsCodename(_ version: Int) -> String? {
        let codename = OsCodenames.shared.getCodeName(version)
        if let codename = codename { return codename }
        else {
            if let codename = OsLicenseParser.parseLICENSE() {
                return codename
            } else {
                return nil
            }
        }
    }
}

struct OsInfo {
    let rawOsInfo: OperatingSystemVersion
    let hostName: String
    let codename: String
    let model: String?
    let uptime: TimeInterval
    init () {
        self.rawOsInfo = ProcessInfo.processInfo.operatingSystemVersion
        self.hostName = OsParser.parseHostName(rawHostName: ProcessInfo.processInfo.hostName)
        self.codename = OsParser.getOsCodename(self.rawOsInfo.majorVersion) ?? ""
        self.model = sysctlString("hw.model")
        self.uptime = ProcessInfo.processInfo.systemUptime
    }
    
    var majorVersion: String  { "\(self.rawOsInfo.majorVersion)" }
    var minorVersion: String  { "\(self.rawOsInfo.minorVersion)" }
    var patchVersion: String  { "\(self.rawOsInfo.patchVersion)" }
    var uptimeFormatted: String {
        let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = .pad
            
        guard let formattedString = formatter.string(from: self.uptime) else { return "0с" }
        
        let pattern = "(\\d+)\\s+([\\w]+)"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(formattedString.startIndex..., in: formattedString)
            
        let result = regex?.stringByReplacingMatches(in: formattedString, options: [],
                                                         range: range, withTemplate: "$1$2") ?? formattedString
        return result
    }
    var fullVersion: String {
        if self.patchVersion == "0" {
            "\(self.majorVersion).\(self.minorVersion)"
        } else {
            "\(self.majorVersion).\(self.minorVersion).\(self.patchVersion)"
        }
    }
}
