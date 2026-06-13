//
//  worker.swift
//  vantuzFetch
//
//  Created by showydima on 14.06.2026.
//
import Foundation
import TOML

class VantuzConfigInitializer {
    
    enum ResourceType {
        case config
        case theme
        var fallbackName: String { "default.toml" }
    }
    
    private let fileManager = FileManager.default
    private let baseDir: URL
    private let configsDir: URL
    private let themesDir: URL
    private let globalConfigFile: URL
    
    init () {
        let home = fileManager.homeDirectoryForCurrentUser
        self.baseDir = home.appendingPathComponent(".config/vantuzFetch")
        self.configsDir = baseDir.appendingPathComponent("configs")
        self.themesDir = baseDir.appendingPathComponent("themes")
        self.globalConfigFile = baseDir.appendingPathComponent("global.toml")
        setupEnvironment()
    }
    
    private func setupEnvironment() {
        try? fileManager.createDirectory(at: configsDir, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: themesDir, withIntermediateDirectories: true)
        
        createFileIfNotExists(at: globalConfigFile, content: DefaultTemplates.globalToml)
        createFileIfNotExists(at: configsDir.appendingPathComponent("default.toml"), content: DefaultTemplates.configToml)
        createFileIfNotExists(at: themesDir.appendingPathComponent("default.toml"), content: DefaultTemplates.themeToml)
    }
    
    private func createFileIfNotExists(at url: URL, content: String) {
        if !fileManager.fileExists(atPath: url.path) {
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    func resolvePath(for userInput: String, type: ResourceType) -> URL {
            var cleanInput = userInput
            if !cleanInput.hasSuffix(".toml") {
                cleanInput += ".toml"
            }
            
            // default folder
            let targetSubfolder = (type == .config) ? configsDir : themesDir
            let fallbackFile = targetSubfolder.appendingPathComponent(type.fallbackName)
            
            // if absolute path
            if cleanInput.hasPrefix("/") || cleanInput.hasPrefix("~") {
                let absoluteURL = URL.fromUserPath(cleanInput)
                if fileManager.fileExists(atPath: absoluteURL.path) {
                    return absoluteURL
                }
            }
            
            // if relative path
            // relative =  ~/.config/vantuzFetch/ + url...
            let relativeURL = baseDir.appendingPathComponent(cleanInput)
            if fileManager.fileExists(atPath: relativeURL.path) {
                return relativeURL
            }
            
            // relative NAME like 'theme.toml' or 'config.toml'
            // serach in related folder (for theme — /themes; for config — /config)
            let shortURL = targetSubfolder.appendingPathComponent(cleanInput)
            if fileManager.fileExists(atPath: shortURL.path) {
                return shortURL
            }
            
            return fallbackFile
    }
    func loadActivePaths() -> (configURL: URL, themeURL: URL) {
        let decoder = TOMLDecoder()
        guard let rawData = try? Data(contentsOf: globalConfigFile),
              let settings = try? decoder.decode(vantuzConfigLocation.self, from: rawData) else {
            return (
                configURL: configsDir.appendingPathComponent(ResourceType.config.fallbackName),
                themeURL: themesDir.appendingPathComponent(ResourceType.theme.fallbackName)
            )
        }

        let activeConfigURL = resolvePath(for: settings.config, type: .config)
        let activeThemeURL = resolvePath(for: settings.theme, type: .theme)
        
        return (configURL: activeConfigURL, themeURL: activeThemeURL)
    }
    func loadConfig(from url: URL) -> vantuzConfig {
        let decoder = TOMLDecoder()
        
        if let rawData = try? Data(contentsOf: url),
           let config = try? decoder.decode(vantuzConfig.self, from: rawData) {
            return config
        }
        
        let fallbackConfig = try! decoder.decode(vantuzConfig.self, from: DefaultTemplates.configToml)
        return fallbackConfig
    }
    func loadTheme(from url: URL) -> vantuzTheme {
        let decoder = TOMLDecoder()
            
        if let rawData = try? Data(contentsOf: url),
           let theme = try? decoder.decode(vantuzTheme.self, from: rawData) {
            return theme
        }
        
        let fallbackTheme = try! decoder.decode(vantuzTheme.self, from: DefaultTemplates.themeToml)
        return fallbackTheme
    }
}

extension URL {
    static func fromUserPath(_ path: String) -> URL {
        let expandingPath = (path as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expandingPath)
    }
}
