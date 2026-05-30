import Foundation



class OsParser {
    static func parseHostName(rawHostName: String) -> String {
        // deletes .local from hostName
        if rawHostName.lowercased().hasSuffix(".local") { return String(rawHostName.dropLast(".local".count)) }
        else { return String(rawHostName.isEmpty ? "localhost" : rawHostName) }
    }

}

struct OsInfo {
//    let rawOsInfo: OperatingSystemVersion
    let hostName: String
//    let codename: String
    let model: String?
    let uptime: TimeInterval
    init () {
//        self.rawOsInfo = ProcessInfo.processInfo.operatingSystemVersion
        self.hostName = OsParser.parseHostName(rawHostName: ProcessInfo.processInfo.hostName)
//        self.codename = OsParser.getOsCodename(self.rawOsInfo.majorVersion) ?? ""
        self.model = sysctlString("hw.model")
        self.uptime = ProcessInfo.processInfo.systemUptime
    }
    

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

}
