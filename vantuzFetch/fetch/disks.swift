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
            .volumeAvailableCapacityKey,
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
                      let available = resource.volumeAvailableCapacity,
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
