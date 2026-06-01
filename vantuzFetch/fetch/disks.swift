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
    
    init (fetchPhysicalNames: Bool) {
        let resourceKeys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeIsInternalKey,
            .volumeIsRemovableKey,
            .volumeIsRootFileSystemKey,
            .volumeIsReadOnlyKey,
        ]
        
        guard let volumesUrls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: resourceKeys, options: [.skipHiddenVolumes]) else {
            isParsed = false
            return
        }
        
        var daSession: DASession? = nil
        if (fetchPhysicalNames) {
            daSession = DASessionCreate(kCFAllocatorDefault)
        }
        
        for url in volumesUrls {
            do {
                let resource = try url.resourceValues(forKeys: Set(resourceKeys))
                
                // fetching volume info
                guard let name = resource.volumeName,
                      let total = resource.volumeTotalCapacity,
                      let available = resource.volumeAvailableCapacityForImportantUsage,
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
    // init ends
}

class Disks {
    let info: [DiskInfo]?
    let isParsed: Bool
    
    init(fetchPhysicalNames: Bool = false) {
        let parser = DisksParser(fetchPhysicalNames: fetchPhysicalNames)
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
    var isFetched: Bool = false
    var results: [FetchResult] = []
    
    var showPhysicalDiskNames: Bool
    
    mutating func run() {
        let parser = DisksParser(fetchPhysicalNames: self.showPhysicalDiskNames)
        var i = 0
        self.isFetched = parser.isParsed
        
        if self.isFetched {
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
                let totalGb = Double(disk.total).asGB().asFormattedString()
                let userGb = Double(disk.usedSpace).asGB().asFormattedString()
                let isSystemDisk = disk.isSystemVolume ? " (System)" : ""
                let isInternal = disk.isInternal ? " (Internal)" : " (External)"
                let isReadOnly = disk.isReadOnly ? " (ReadOnly)" : ""
                let usedPercent = Int(round(disk.usedSpace.asGB() / disk.total.asGB() * 100))
                self.results.append(FetchResult(keyId: "\(self.id)_\(i)_\(disk.volumeName)\(physicalName)", value: "\(userGb)GB / \(totalGb)GB (\(usedPercent)%)\(isSystemDisk)\(isInternal)\(isReadOnly)"))
                i += 1
            }
        }
    }

}
