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

func analyzeSrcDir(srcURL: URL) -> dirOverall {
    var overall = dirOverall(maxLengthPath: "PATH".count,
                             maxLengthDirs: "DIRS".count,
                             maxLengthFiles: "FILES".count,
                             maxLengthPlaceholders: "PLACEHOLDERS".count,
                             maxLengthHidden: "HIDDEN".count,
                             maxLengthSizeFiles: "SIZE".count,
                             maxLengthSizeOffloaded: "OFFLOADED".count,
                             maxLengthTotal: "TOTAL".count,
                             totalDirs: 0,
                             totalFiles: 0,
                             totalPlaceholders: 0,
                             totalHidden: 0,
                             totalSizeFiles: 0,
                             totalSizeOffloaded: 0,
                             stats: [])
    
    let childDirs = getChildDirs(url: srcURL)
    for childDir in childDirs {
        let childStats = walkDir(baseURL: childDir)
        
        if childStats.path.count > overall.maxLengthPath {
            overall.maxLengthPath = childStats.path.count
        }
        
        if String(childStats.numberOfDirs).count > overall.maxLengthDirs {
            overall.maxLengthDirs = String(childStats.numberOfDirs).count
        }
        
        if String(childStats.numberOfFiles).count > overall.maxLengthFiles {
            overall.maxLengthFiles = String(childStats.numberOfFiles).count
        }
        
        if String(childStats.numberOfPlaceholders).count > overall.maxLengthPlaceholders {
            overall.maxLengthPlaceholders = String(childStats.numberOfPlaceholders).count
        }
        
        if String(childStats.numberOfHidden).count > overall.maxLengthHidden {
            overall.maxLengthHidden = String(childStats.numberOfHidden).count
        }
        
        if getSizeString(byteCount: childStats.sizeFiles).count > overall.maxLengthSizeFiles {
            overall.maxLengthSizeFiles = getSizeString(byteCount: childStats.sizeFiles).count
        }
        
        if getSizeString(byteCount: childStats.sizeOffloaded).count > overall.maxLengthSizeOffloaded {
            overall.maxLengthSizeOffloaded = getSizeString(byteCount: childStats.sizeOffloaded).count
        }
        
        overall.totalDirs += childStats.numberOfDirs
        overall.totalFiles += childStats.numberOfFiles
        overall.totalPlaceholders += childStats.numberOfPlaceholders
        overall.totalHidden += childStats.numberOfHidden
        overall.totalSizeFiles += childStats.sizeFiles
        overall.totalSizeOffloaded += childStats.sizeOffloaded
        
        overall.stats.append(childStats)
    }
    return overall
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
        
        if fileIsPlaceholder(url: elementURL) {
            stats.numberOfPlaceholders += 1
            stats.sizeOffloaded += getSizeOfOffloadedContent(url: elementURL)
            continue
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
