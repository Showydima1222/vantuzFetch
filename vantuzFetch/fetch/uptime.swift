//
//  uptime.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//
import Foundation

struct OSUptimeModule: FetchableModule {
    let id: String = "uptime"
    var isFetched: Bool = false
    var results: [FetchResult] = []
    mutating func run() {
        let uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
        var uptimeFormatted: String {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = .pad
            
            let oneDay: TimeInterval = 60 * 60 * 24
            let oneMonth: TimeInterval = 60 * 60 * 24 * 30
            
            if uptime >= oneMonth { formatter.allowedUnits = [.month, .day, .hour]
            } else 
            if uptime >= oneDay { formatter.allowedUnits = [.day, .hour, .minute]
            } else { formatter.allowedUnits = [.hour, .minute, .second]
            }
                
            guard let formattedString = formatter.string(from: uptime) else { return "error while formating" }
            
            let regex = try? NSRegularExpression(pattern: "(\\d+)\\s+(\\w+)")
            let range = NSRange(formattedString.startIndex..., in: formattedString)
                
            return regex?.stringByReplacingMatches(in: formattedString, 
                                                options: [], 
                                                range: range, 
                                                withTemplate: "$1$2") ?? formattedString
        }
        self.results = [FetchResult(keyId: self.id, value: uptimeFormatted)]
    }
}