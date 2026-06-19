//
//  uptime.swift
//  vantuzFetch
//
//  Created by showydima on 30.05.2026.
//
import Foundation

let oneDay: TimeInterval = 60 * 60 * 24
let oneMonth: TimeInterval = 60 * 60 * 24 * 30

struct TimeModuleParser {
    static let shared = TimeModuleParser()
    
    private let monthFormatter: DateComponentsFormatter
    private let dayFormatter: DateComponentsFormatter
    private let hourFormatter: DateComponentsFormatter
    
    private let regex = try? NSRegularExpression(pattern: "(\\d+)\\s+(\\w+)")
    
    private let oneMonth: TimeInterval = 2592000
    private let oneDay: TimeInterval = 86400
    
    private init() {
        let baseFormatter = { (units: NSCalendar.Unit) -> DateComponentsFormatter in
            let f = DateComponentsFormatter()
            f.unitsStyle = .abbreviated
            f.zeroFormattingBehavior = .pad
            f.allowedUnits = units
            return f
        }
        
        self.monthFormatter = baseFormatter([.month, .day, .hour])
        self.dayFormatter = baseFormatter([.day, .hour, .minute])
        self.hourFormatter = baseFormatter([.hour, .minute, .second])
    }
    
    func formatTime(_ time: Int) -> String {
        return formatTime(TimeInterval(time))
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let formatter: DateComponentsFormatter
        if time >= oneMonth { formatter = monthFormatter }
        else if time >= oneDay { formatter = dayFormatter }
        else { formatter = hourFormatter }
        
        guard let formattedString = formatter.string(from: time) else {
            return "error while formatting"
        }
        
        let range = NSRange(formattedString.startIndex..., in: formattedString)
        return regex?.stringByReplacingMatches(in: formattedString,
                                               options: [],
                                               range: range,
                                               withTemplate: "$1$2") ?? formattedString
    }
}
struct OSUptimeModule: FetchableModule {
    let id: String = "uptime"
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        let parser = TimeModuleParser.shared
        let uptime: TimeInterval = ProcessInfo.processInfo.systemUptime
        results = [FetchResult(keyId: self.id, value: parser.formatTime(uptime))]
        return results
    }
}

struct WakeTimeModule: FetchableModule {
    let id: String = "waketime"
    
    func run() -> [FetchResult] {
        let waketime = sysctlTime("kern.waketime")
        guard let waketime else { return [] }
        return [FetchResult(keyId: "waketime", value: TimeModuleParser.shared.formatTime(Date.now.timeIntervalSince1970 - Double(waketime)))]
    }
}
