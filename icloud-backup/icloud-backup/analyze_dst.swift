//
//  walk.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation

struct dstDirStats {
    var start: Date
    var end: Date?
    
    var dirCount: Int64
    var fileCount: Int64
    var fileSize: Int64
    
    var dirsToDelete: [URL]

    var filesToDelete: [URL]
    var filesToDeleteSize: Int64
    
    var filesToDeleteBanlist: [URL]
    var filesToDeleteBanlistSize: Int64
}

func analyzeDstDir(dstURL: URL, srcURL: URL) -> dstDirStats {
    var stats = dstDirStats(start: Date(),
                            end: nil,
                            dirCount: 0,
                            fileCount: 0,
                            fileSize: 0,
                            dirsToDelete: [URL](),
                            filesToDelete: [URL](),
                            filesToDeleteSize: 0,
                            filesToDeleteBanlist: [URL](),
                            filesToDeleteBanlistSize: 0)
    
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: dstURL.path) else {
        print("Directory not found")
        return stats
    }
    
    while let element = enumerator.nextObject() as? String {
        // Build URL that this element has at dst
        var dstElementURL: URL = URL(fileURLWithPath: dstURL.path)
        dstElementURL.appendPathComponent(element)
        
        // Build URL that this element would have if it exists at src
        var srcElementURL: URL = URL(fileURLWithPath: srcURL.path)
        srcElementURL.appendPathComponent(element)
        
        // Build URL that this element would have if it exists at src if it's just a placeholder
        var srcElementPlaceholderURL: URL = URL(fileURLWithPath: srcURL.path)
        srcElementPlaceholderURL.appendPathComponent(element)
        srcElementPlaceholderURL.deleteLastPathComponent()
        srcElementPlaceholderURL.appendPathComponent("." + dstElementURL.lastPathComponent + ".icloud")

        if let values = try? dstElementURL.resourceValues(forKeys: [.isDirectoryKey]) {
            if values.isDirectory! {
                stats.dirCount += 1
                
                var isDir: ObjCBool = true
                if !fileManager.fileExists(atPath: srcElementURL.path, isDirectory:&isDir) {
                    stats.dirsToDelete.append(dstElementURL)
                }
            } else {
                stats.fileCount += 1
                
                var fileSize: Int64
                do {
                    let attr = try fileManager.attributesOfItem(atPath: dstElementURL.path)
                    fileSize = attr[FileAttributeKey.size] as! Int64
                } catch {
                    fileSize = 0
                }
                stats.fileSize += fileSize
                
                // Banlist 1/2: File is actually a placeholder
                if let fileType: String = dstElementURL.typeIdentifier {
                    if fileType == "com.apple.icloud-file-fault" {
                        stats.filesToDeleteBanlist.append(dstElementURL)
                        stats.filesToDeleteBanlistSize += fileSize
                        continue
                    }
                }
                
                // Banlist 2/2: File is .DS_Store
                if dstElementURL.lastPathComponent == ".DS_Store" {
                    stats.filesToDeleteBanlist.append(dstElementURL)
                    stats.filesToDeleteBanlistSize += fileSize
                    continue
                }
                
                var isDir: ObjCBool = false
                if !fileManager.fileExists(atPath: srcElementURL.path, isDirectory:&isDir) {
                    if !fileManager.fileExists(atPath: srcElementPlaceholderURL.path, isDirectory:&isDir) {
                        stats.filesToDelete.append(dstElementURL)
                        stats.filesToDeleteSize += fileSize
                    }
                }
            }
        }
    }
    
    stats.end = Date()
    return stats
}
