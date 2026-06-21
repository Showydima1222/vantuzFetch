//
//  disks.swift
//  vantuzFetch
//
//  Created by showydima on 06.04.2026.
//

import Foundation
import DiskArbitration

struct DiskInfo {
    let volumeName: String
    let mountPath: String
    let total: UInt64
    let available: UInt64
    let isInternal: Bool
    let isSystemVolume: Bool
    let isReadOnly: Bool
    var usedSpace: UInt64 {
        return total - available
    }
    let physicalName: String?
}

class DisksParser {
    var parsedDisks: [DiskInfo] = []
    let isParsed: Bool
    
    init (fetchPhysicalNames: Bool, fastVolumeSizeCalculation: Bool) {
        let resourceKeys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            !fastVolumeSizeCalculation ? .volumeAvailableCapacityForImportantUsageKey : .volumeAvailableCapacityKey,
            .volumeIsInternalKey,
            .volumeIsRemovableKey,
            .volumeIsRootFileSystemKey,
            .volumeIsReadOnlyKey,
        ]
        
        guard let volumesUrls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: resourceKeys, options: [.skipHiddenVolumes]) else {
            isParsed = false
            return
        }
        
        
        let daSession: DASession? = DASessionCreate(kCFAllocatorDefault)
        
        for url in volumesUrls {
            do {
                let resource = try url.resourceValues(forKeys: Set(resourceKeys))
                
                // fetching volume info
                guard let name = resource.volumeName,
                      let total = resource.volumeTotalCapacity,
                      let available = !fastVolumeSizeCalculation ? resource.volumeAvailableCapacityForImportantUsage : resource.volumeAvailableCapacity.map(Int64.init),
                      let isInternal = resource.volumeIsInternal,
                      let isRemovable = resource.volumeIsRemovable,
                      let isSystemVolume = resource.volumeIsRootFileSystem,
                      let isReadOnly = resource.volumeIsReadOnly
                else {
                    continue
                }

                
                // fetch physical disk
                var physicalName: String? = nil
                if fetchPhysicalNames, let session = daSession,
                   let disk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, url as CFURL),
                   let description = DADiskCopyDescription(disk) as? [String: Any] {
                    if let modelName = description[kDADiskDescriptionDeviceModelKey as String] as? String {
                        physicalName = modelName.trimmingCharacters(in: .whitespacesAndNewlines)
                    } else if let mediaName = description[kDADiskDescriptionMediaNameKey as String] as? String {
                        physicalName = mediaName.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                let fixedIsInternal: Bool = isInternal && !isRemovable
                let currentDiskInfo = DiskInfo(volumeName: name, mountPath: url.path, total: UInt64(total), available: UInt64(available), isInternal: fixedIsInternal, isSystemVolume: isSystemVolume,
                                               isReadOnly: isReadOnly, physicalName: physicalName)
                
                self.parsedDisks.append(currentDiskInfo)
            } catch {
                continue
            }
        }
        self.isParsed = !self.parsedDisks.isEmpty
    }
}

class Disks {
    let info: [DiskInfo]?
    let isParsed: Bool
    
    init(fetchPhysicalNames: Bool = false, fastVolumeSizeCalculation: Bool = false) {
        let parser = DisksParser(fetchPhysicalNames: fetchPhysicalNames, fastVolumeSizeCalculation: fastVolumeSizeCalculation)
        self.isParsed = parser.isParsed
        if self.isParsed {
            self.info = parser.parsedDisks
        } else {
            self.info = nil
        }
    }
}

struct DisksModule: FetchableModule {
    let id: String = "disks"

    var showPhysicalDiskNames: Bool
    var fastVolumeSizeCalculation: Bool
    
    func run() -> [FetchResult] {
        var results: [FetchResult] = []
        let parser = DisksParser(fetchPhysicalNames: self.showPhysicalDiskNames, fastVolumeSizeCalculation: self.fastVolumeSizeCalculation)
        var i = 0
        
        if parser.isParsed {
            let orderedDisks = parser.parsedDisks.sorted {
                (lhs, rhs) -> Bool in
                func priority (for disk: DiskInfo) -> Int {
                    if disk.isSystemVolume { return 0 }
                    if disk.isInternal { return 1 }
                    return 2
                }
                let p1 = priority(for: lhs)
                let p2 = priority(for: rhs)
                if p1 != p2 { return p1 < p2 }
                
                return lhs.volumeName.localizedCompare(rhs.volumeName) == .orderedAscending
            }

            for disk in orderedDisks {
                let physicalName: String = disk.physicalName != nil ? ", \(disk.physicalName!)" : ""
                let totalGb: String  = disk.total.autoSI()
                let userGb:  String  = disk.usedSpace.autoSI()
                let isSystemDisk = disk.isSystemVolume ? " (System)" : ""
                let isInternal = disk.isInternal ? " (Internal)" : " (External)"
                let isReadOnly = disk.isReadOnly ? " (ReadOnly)" : ""
                let usedPercent = Int(round(disk.usedSpace.asGB() / disk.total.asGB() * 100))
                results.append(FetchResult(keyId: "\(self.id)_\(i)_\(disk.volumeName)\(physicalName)", value: "\(userGb) / \(totalGb) (\(usedPercent)%)\(isSystemDisk)\(isInternal)\(isReadOnly)"))
                i += 1
            }
        }
        return results
    }

}
