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
    let isColorSupported: Bool
    let validColors: vantuzColors
    let logo: [String]?
    
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
    
    static func _getTerminalWidth() -> UInt16? {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            return w.ws_col
        }
        return nil
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
        case "mem_pressure": return self.theme.strings.memPressureTitle
        case "swap": return self.theme.strings.swapTitle
            
        default: return "idk"
        }
    }
    
    private func visibleLength(of input: String) -> Int {
        var count = 0
        var insideANSI = false
        for char in input {
            if char == "\u{1B}" { insideANSI = true; continue }
            if insideANSI {
                if char.isASCII && char.isLetter { insideANSI = false }
                continue
            }
            count += 1
        }
        return count
    }
    
    func renderAllModules(modules: [[FetchResult]]) {
            let flatModules = Array(modules.joined())
            let themePolicy = WrapPolicy(rawValue: self.theme.text.wrapPolicy) ?? .smart
            
            var currentLogoIndex = 0
            var currentModuleIndex = 0
            
            while currentModuleIndex < flatModules.count || currentLogoIndex < (self.logo?.count ?? 0) {
                if currentModuleIndex < flatModules.count {
                    let result = flatModules[currentModuleIndex]
                    var currentPolicy = themePolicy
                    
                    // Приоритет 4: Fallback на crop
                    if currentPolicy == .smart && !result.canBeSmartWrapped {
                        currentPolicy = .crop
                    }
                    
                    let linesPrinted = self.renderLine(
                        logoIndex: currentLogoIndex,
                        key_title: result.keyId,
                        value: result.value,
                        wrapPolicy: currentPolicy
                    )
                    currentLogoIndex += linesPrinted
                    currentModuleIndex += 1
                } else {
                    _ = self.renderLine(logoIndex: currentLogoIndex, key_title: "", value: "", wrapPolicy: .none)
                    currentLogoIndex += 1
                }
            }
        }
    func renderLine(logoIndex: Int, key_title: String, value: String, wrapPolicy: WrapPolicy = .smart) -> Int {
            if key_title.isEmpty && value.isEmpty {
                let logoPart = renderLogoPart(self.logo, atIndex: logoIndex)
                print(logoPart.line)
                return 1
            }
            
            let title = _getTitle(key_title: key_title)
            let rawValueOutput = value
                .replacing("{{ ACCENT_COLOR }}", with: "")
                .replacing("{{ TEXT }}", with: "")
            
            let colorfulOutput = value
                .replacing("{{ ACCENT_COLOR }}", with: self.validColors.accent)
                .replacing("{{ TEXT }}", with: self.validColors.text)
            
            let finalTitle: String
            let finalValue: String
            
            if self.isColorSupported {
                finalTitle = "\(self.validColors.title)\(title)\(vantuzRender.reset): "
                finalValue = "\(self.validColors.text)\(colorfulOutput)\(vantuzRender.reset)"
            } else {
                finalTitle = "\(title): "
                finalValue = rawValueOutput
            }
            
            let finalText = finalTitle + finalValue
            let terminalWidth = Int(vantuzRender._getTerminalWidth() ?? 0)
            let actualPolicy: WrapPolicy = (terminalWidth > 0 && self.isColorSupported) ? wrapPolicy : .none
            
            switch actualPolicy {
            case .none:
                let logoPart = renderLogoPart(self.logo, atIndex: logoIndex)
                print(logoPart.line + finalText)
                return 1
                
            case .crop:
                let logoPart = renderLogoPart(self.logo, atIndex: logoIndex)
                let croppedLine = cropStringWithANSI(logoPart.line + finalText, maxLength: terminalWidth)
                print(croppedLine + vantuzRender.reset)
                return 1
                
            case .smart:
                let baseLogoPart = renderLogoPart(self.logo, atIndex: logoIndex)
                let textWidth = terminalWidth - baseLogoPart.actualLength
                
                if textWidth <= 0 {
                    let croppedLine = cropStringWithANSI(baseLogoPart.line + finalText, maxLength: terminalWidth)
                    print(croppedLine + vantuzRender.reset)
                    return 1
                }
                
                let words = finalText.components(separatedBy: " ")
                var currentLine = ""
                var currentVisibleLength = 0
                var linesPrinted = 0
                var activeLogoIndex = logoIndex
                var activeANSI = ""
                
                for word in words {
                    let wordLength = visibleLength(of: word)
                    let spaceLength = currentVisibleLength > 0 ? 1 : 0
                    
                    if currentVisibleLength + spaceLength + wordLength > textWidth {
                        if currentVisibleLength == 0 {
                            let logo = renderLogoPart(self.logo, atIndex: activeLogoIndex)
                            print(logo.line + activeANSI + word + vantuzRender.reset)
                            linesPrinted += 1
                            activeLogoIndex += 1
                            updateActiveANSI(&activeANSI, with: word)
                        } else {
                            let logo = renderLogoPart(self.logo, atIndex: activeLogoIndex)
                            print(logo.line + currentLine + vantuzRender.reset)
                            linesPrinted += 1
                            activeLogoIndex += 1
                            
                            // Пробрасываем накопленный ANSI-цвет на новую строку
                            currentLine = activeANSI + word
                            currentVisibleLength = wordLength
                            updateActiveANSI(&activeANSI, with: word)
                        }
                    } else {
                        if currentVisibleLength > 0 {
                            currentLine += " "
                            currentVisibleLength += 1
                        } else {
                            currentLine += activeANSI
                        }
                        currentLine += word
                        currentVisibleLength += wordLength
                        updateActiveANSI(&activeANSI, with: word)
                    }
                }
                
                if !currentLine.isEmpty {
                    let logo = renderLogoPart(self.logo, atIndex: activeLogoIndex)
                    print(logo.line + currentLine + vantuzRender.reset)
                    linesPrinted += 1
                }
                
                return linesPrinted > 0 ? linesPrinted : 1

            }
        }


    private func updateActiveANSI(_ current: inout String, with text: String) {
        var insideANSI = false
        var currentSeq = ""
        for char in text {
            if char == "\u{1B}" {
                insideANSI = true
                currentSeq = String(char)
                continue
            }
            if insideANSI {
                currentSeq.append(char)
                if char.isASCII && char.isLetter {
                    insideANSI = false
                    if currentSeq == vantuzRender.reset {
                        current = ""
                    } else {
                        current = currentSeq
                    }
                    currentSeq = ""
                }
            }
        }
    }

        
    private func renderLogoPart(_ logo: [String]?, atIndex index: Int) -> LogoPart {
        guard let logo, !logo.isEmpty else { return LogoPart(line: "", actualLength: 0) }

        let logoWidth = logo.map { $0.count }.max() ?? 0

        if index < logo.count {
            let line = logo[index]
            let spacing = "   "
            return LogoPart(line: self.validColors.accent + line.padding(toLength: logoWidth, withPad: " ", startingAt: 0) + spacing + self.validColors.text, actualLength: logoWidth + spacing.count)
        } else {
            return LogoPart(line: String(repeating: " ", count: logoWidth + 3), actualLength: logoWidth + 3)
        }
    }
    
    func cropStringWithANSI(_ input: String, maxLength: Int) -> String {
        var result = ""
        var visibleCount = 0
        var insideANSI = false

        for char in input {
            if char == "\u{1B}" { // Начало escape-последовательности (ESC)
                insideANSI = true
                result.append(char)
                continue
            }

            if insideANSI {
                result.append(char)
                // Конец стандартного ANSI-кода (SGR) всегда обозначается латинской буквой, чаще всего 'm'
                if char.isASCII && char.isLetter {
                    insideANSI = false
                }
                continue
            }

            if visibleCount < maxLength {
                result.append(char)
                visibleCount += 1
            } else {
                // Лимит достигнут, прекращаем сборку строки
                break
            }
        }
        return result
    }

}


struct LogoPart {
    let line: String
    let actualLength: Int
}
