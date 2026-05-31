//import Foundation
//
//
//
//class OsParser {
//    static func parseHostName(rawHostName: String) -> String {
//        // deletes .local from hostName
//        if rawHostName.lowercased().hasSuffix(".local") { return String(rawHostName.dropLast(".local".count)) }
//        else { return String(rawHostName.isEmpty ? "localhost" : rawHostName) }
//    }
//
//}

//struct OsInfo {
//    let rawOsInfo: OperatingSystemVersion
    // let hostName: String
//    let codename: String
//    let model: String?
    // let uptime: TimeInterval``
//    init () {
//        self.rawOsInfo = ProcessInfo.processInfo.operatingSystemVersion
        // self.hostName = OsParser.parseHostName(rawHostName: ProcessInfo.processInfo.hostName)
//        self.codename = OsParser.getOsCodename(self.rawOsInfo.majorVersion) ?? ""
//        self.model = sysctlString("hw.model")
        // self.uptime = ProcessInfo.processInfo.systemUptime
//    }
    

//     var uptimeFormatted: String {
//     let formatter = DateComponentsFormatter()
//     formatter.unitsStyle = .abbreviated
//     formatter.zeroFormattingBehavior = .pad
    
//     let oneDay: TimeInterval = 60 * 60 * 24
//     let oneMonth: TimeInterval = 60 * 60 * 24 * 30
    
//     if self.uptime >= oneMonth { formatter.allowedUnits = [.month, .day, .hour]
//     } else 
//     if self.uptime >= oneDay { formatter.allowedUnits = [.day, .hour, .minute]
//     } else { formatter.allowedUnits = [.hour, .minute, .second]
//     }
        
//     guard let formattedString = formatter.string(from: self.uptime) else { return "error while formating" }
    
//     let regex = try? NSRegularExpression(pattern: "(\\d+)\\s+(\\w+)")
//     let range = NSRange(formattedString.startIndex..., in: formattedString)
        
//     return regex?.stringByReplacingMatches(in: formattedString, 
//                                            options: [], 
//                                            range: range, 
//                                            withTemplate: "$1$2") ?? formattedString
// }

//}
