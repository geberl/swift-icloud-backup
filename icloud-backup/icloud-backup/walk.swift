//
//  walk.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//


import Foundation


struct dirOverall {
    var maxLengthPath: Int
    var maxLengthDirs: Int
    var maxLengthFiles: Int
    var maxLengthPlaceholders: Int
    var maxLengthHidden: Int
    var maxLengthSizeFiles: Int
    var maxLengthSizeOffloaded: Int
    var maxLengthTotal: Int
    
    var totalDirs: Int
    var totalFiles: Int
    var totalPlaceholders: Int
    var totalHidden: Int
    var totalSizeFiles: Int64
    var totalSizeOffloaded: Int64
    
    var stats: [dirStats]
}

struct dirStats {
    var path: String
    
    var numberOfDirs: Int
    var numberOfFiles: Int
    var numberOfPlaceholders: Int
    var numberOfHidden: Int
    
    var sizeFiles: Int64
    var sizeOffloaded: Int64
}


func getChildDirs(url: URL) -> [URL] {
    let fileManager = FileManager.default
    var itemURLs: [URL] = []
    var dirURLs: [URL] = []
    
    do {
        itemURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    } catch {
        print("Error while enumerating files \(url.path): \(error.localizedDescription)")
        return dirURLs
    }
    
    for itemURL in itemURLs {
        if let saveIsDir = fileManager.isDirectory(url: itemURL) {
            if saveIsDir == true {
                dirURLs.append(itemURL)
            }
        }
    }
    
    return dirURLs.sorted(by: { $0.path < $1.path })
}


func walkDir(baseURL: URL) -> dirStats {

    var stats = dirStats(path: baseURL.path,
                         numberOfDirs: 0,
                         numberOfFiles: 0,
                         numberOfPlaceholders: 0,
                         numberOfHidden: 0,
                         sizeFiles: 0,
                         sizeOffloaded: 0)
    
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: stats.path) else {
        print("Directory not found")
        return stats
    }
    
    while let element = enumerator.nextObject() as? String {
        var elementURL: URL = URL(fileURLWithPath: stats.path)
        elementURL.appendPathComponent(element)
        
        var fileSize: Int64
        do {
            let attr = try fileManager.attributesOfItem(atPath: elementURL.path)
            fileSize = attr[FileAttributeKey.size] as! Int64
        } catch {
            fileSize = 0
        }
        stats.sizeFiles += fileSize
        
        if let fileType: String = elementURL.typeIdentifier {
            if fileType == "com.apple.icloud-file-fault" {
                stats.numberOfPlaceholders += 1
                stats.sizeOffloaded += getSizeOfOffloadedContent(url: elementURL)
                continue
            }
        }
        
        if let values = try? elementURL.resourceValues(forKeys: [.isDirectoryKey]) {
            if values.isDirectory! {
                stats.numberOfDirs += 1
            } else {
                if element.starts(with: ".") {
                    stats.numberOfHidden += 1
                } else {
                    stats.numberOfFiles += 1
                }
            }
        }
    }
    
    return stats
}
