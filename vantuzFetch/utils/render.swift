//
//  render.swift
//  vantuzFetch
//
//  Created by showydima on 25.08.2026.
//
import Foundation
import Darwin

enum WrapPolicy: String {
    case smart
    case crop
    case none
}

struct vantuzRender {
    static let ansiSystemColors: [String: String] = [
        "black": "30", "red": "31", "green": "32", "yellow": "33",
        "blue": "34", "magenta": "35", "cyan": "36", "white": "37",
        "bright_black": "90", "bright_red": "91", "bright_green": "92", "bright_yellow": "93",
        "bright_blue": "94", "bright_magenta": "95", "bright_cyan": "96", "bright_white": "97"
    ]
    static let reset = "\u{001B}[0m"
    let theme: vantuzTheme
    let terminalSize: (rows: UInt16, cols: UInt16)
    let isColorSupported: Bool
    let validColors: vantuzColors
    let logo: [String]?
    
    static func _getTerminalWidth() -> UInt16? {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            return w.ws_col
        }
        return nil
    }
    
    static func _parseHex(_ colorValue: String, fallbackColor: String = "\u{001B}[0m") -> String {
        let cleanedInput = colorValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let colorLower = cleanedInput.lowercased()
        
        if let systemCode = vantuzRender.ansiSystemColors[colorLower] {
            return "\u{001B}[\(systemCode)m"
        }
        
        var hexStr = cleanedInput.uppercased()
        if hexStr.hasPrefix("#") {
            hexStr.removeFirst()
        }
        
        let range = NSRange(location: 0, length: hexStr.utf16.count)
        let regex = try! NSRegularExpression(pattern: "^[0-9A-F]{3}$|^[0-9A-F]{6}$")
        
        guard regex.firstMatch(in: hexStr, options: [], range: range) != nil else {
            return fallbackColor
        }
        
        if hexStr.count == 3 {
            hexStr = hexStr.map { String($0) + String($0) }.joined()
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&rgbValue)
        
        let r = Int((rgbValue & 0xFF0000) >> 16)
        let g = Int((rgbValue & 0x00FF00) >> 8)
        let b = Int(rgbValue & 0x0000FF)
        
        return "\u{001B}[38;2;\(r);\(g);\(b)m"
    }
    
    init(theme: vantuzTheme, logo: [String]?) {
        self.theme = theme
        self.terminalSize = vantuzRender._getTerminalSize()
        self.isColorSupported = isatty(STDOUT_FILENO) == 1
        
        validColors = vantuzColors(
            title: vantuzRender._parseHex(theme.colors.title, fallbackColor: "yellow"),
            accent: vantuzRender._parseHex(theme.colors.accent, fallbackColor: "bright_yellow"),
            text: vantuzRender._parseHex(theme.colors.text, fallbackColor: "bright_white")
        )
        self.logo = logo
    }
    
    func _getTitle (key_title: String) -> String {
        let rawTitle = self._getTitleRaw(key_title: key_title)
        let raw = key_title.split(separator: "_")
        let number = raw.count > 1 ? String(raw[1]) : "0"
        var name: String = ""
        if raw.count > 2 {
            if raw[0] == "disks" {
                name = String(raw[2])
            }
        }
        
        return rawTitle
            .replacing("{num}", with: number)
            .replacing("{name}", with: name)
    }
    
    static func _getTerminalSize() -> (rows: UInt16, cols: UInt16) {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            return (w.ws_row, w.ws_col)
        }
        return (24, 80)
    }
    
    func _getTitleRaw(key_title: String) -> String {
        switch key_title.split(separator: "_").first {
        case "os": return self.theme.strings.osTitle
        case "kernel": return self.theme.strings.kernelTitle
        case "machine": return self.theme.strings.machineTitle
        case "uptime": return self.theme.strings.uptimeTitle
        case "terminal": return self.theme.strings.terminalTitle
        case "shell": return self.theme.strings.shellTitle
        case "waketime": return self.theme.strings.waketimeTitle
        case "host": return self.theme.strings.hostTitle
        case "gpu": return self.theme.strings.gpuTitle
        case "display": return self.theme.strings.displayTitle
        case "disks": return self.theme.strings.disksTitle
        case "cpu": return self.theme.strings.cpuTitle
        case "mem": return self.theme.strings.memTitle
        case "swap": return self.theme.strings.swapTitle
            
        default: return "idk"
        }
    }
    
    func renderAllModules(modules: [[FetchResult]]) {
        let range = max(modules.joined().count, self.logo?.count ?? 0)
        var j = 0
        for i in 0..<range {
            let isEmpty = j >= modules.count
            
            if !isEmpty {
                for result in modules[i] {
                    let _wrap: WrapPolicy = result.canBeWrapped ? WrapPolicy(rawValue: self.theme.text.wrapPolicy) ?? .smart : .none
                    self.renderLine(index: j, key_title: result.keyId, value: result.value, wrapPolicy: _wrap)
                    j += 1
                }
            } else {
                self.renderLine(index: j, key_title: "", value: "", wrapPolicy: .none)
                j += 1
            }
        }
    }
    
    func renderLine(index: Int, key_title: String, value: String, wrapPolicy: WrapPolicy = .smart) {
        let title = _getTitle(key_title: key_title)
        let colorfulOutput = value
            .replacing("{{ ACCENT_COLOR }}", with: self.validColors.accent)
            .replacing("{{ TEXT }}", with: self.validColors.text)
        
        
        let logoPart = renderLogoPart(self.logo, atIndex: index)
        
        let infoLine: String
        if key_title == "" && value == "" {
            print(logoPart)
            return
        }
        if self.isColorSupported {
            infoLine = "\(self.validColors.title)\(title): \(self.validColors.text)\(colorfulOutput)\(vantuzRender.reset)"
        } else {
            infoLine = "\(title): \(value)"
        }
        print(logoPart + infoLine)
    }
    
    private func renderLogoPart(_ logo: [String]?, atIndex index: Int) -> String {
        guard let logo, !logo.isEmpty else { return "" }

        let logoWidth = logo.map { $0.count }.max() ?? 0

        if index < logo.count {
            let line = logo[index]
            return self.validColors.accent + line.padding(toLength: logoWidth, withPad: " ", startingAt: 0) + "   " + self.validColors.text
        } else {
            return String(repeating: " ", count: logoWidth + 3)
        }
    }
}
