//
//  display.swift
//  vantuzFetch
//
//  Created by showydima on 02.07.2026.
//
import Foundation
import CoreGraphics

class DisplayParser {
    static func getActiveDisplays() -> [CGDirectDisplayID] {
        let maxDisplays: UInt32 = 16
        var activeDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var displayCount: UInt32 = 0
        
        let error = CGGetActiveDisplayList(maxDisplays, &activeDisplays, &displayCount)
        
        guard error == .success else {
            return []
        }
        
        return Array(activeDisplays.prefix(Int(displayCount)))
    }
}

struct DisplayModule: FetchableModule {
    let id: String = "display"
    let isHeavy: Bool = true
    
    func run() -> [FetchResult] {
        let displaysId = DisplayParser.getActiveDisplays()
        var buffer: [FetchResult] = []
        var counter: Int = 0
        
        for display in displaysId {
            guard let mode = CGDisplayCopyDisplayMode(display) else { continue }
            
            let pixelWidth = Double(mode.pixelWidth)
            let pixelHeight = Double(mode.pixelHeight)
            let displayResolution: String
            if mode.pixelWidth > mode.width {
                let scaleFactor = Double(mode.pixelWidth) / Double(mode.width)
                let scaleString = scaleFactor.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(scaleFactor)) : String(format: "%.1f", scaleFactor)
                displayResolution = "\(mode.width)×\(mode.height) (Retina, \(mode.pixelWidth)×\(mode.pixelHeight) @ \(scaleString)x)"
            }
            else { displayResolution = "\(mode.width)×\(mode.height)" }
            
            let mmSize = CGDisplayScreenSize(display)
            let mmWidth = Double(mmSize.width)
            let mmHeight = Double(mmSize.height)
            
            var metricsString = ""
            
            if mmWidth > 0 && mmHeight > 0 {
                let inchesWidth = mmWidth / 25.4
                let inchesHeight = mmHeight / 25.4
                
                let diagonalInches = sqrt(pow(inchesWidth, 2) + pow(inchesHeight, 2))
                let diagonalPixels = sqrt(pow(pixelWidth, 2) + pow(pixelHeight, 2))
                
                let ppi = Int(round(diagonalPixels / diagonalInches))
                let roundedInches = round(diagonalInches * 10) / 10
                
                metricsString = " (\(roundedInches)\", \(ppi) PPI)"
            }
            
            
            let refreshRate: String = mode.refreshRate.formatted()
            let displayRefreshRate = mode.refreshRate > 0 ? " @ \(refreshRate)Hz" : ""
            
            let isMain = CGDisplayIsMain(display) == 1 ? " (Main)" : ""
            
            let resultString = "\(displayResolution)\(displayRefreshRate)\(metricsString)\(isMain)"
            
            buffer.append(FetchResult(keyId: "display_\(counter)", value: resultString, canBeSmartWrapped: true))
            counter += 1
        }
        return buffer
    }
}
