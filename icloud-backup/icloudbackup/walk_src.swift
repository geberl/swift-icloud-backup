import Foundation

struct srcDirStats {
    var start: Date
    var end: Date?
    
    var dirCount: Int64
    var fileCount: Int64
    var fileSize: Int64
    
    var dirsToCreate: [URL]
    
    var filesToCopy: [URLPair]
    var filesToCopySize: Int64
    
    var filesToOverwrite: [URLPair]
    var filesToOverwriteSize: Int64
    
    var filesToDownloadAndCopy: [URLPair]
    var filesToDownloadAndCopySize: Int64
    
    var filesToDownloadAndOverwrite: [URLPair]
    var filesToDownloadAndOverwriteSize: Int64
    
    var filesToDeleteBanlist: [URL]
    var filesToDeleteBanlistSize: Int64
}

func analyzeSrcDir(srcURL: URL, dstURL: URL) -> srcDirStats {
    var stats = srcDirStats(start: Date(),
                            end: nil,
                            dirCount: 0,
                            fileCount: 0,
                            fileSize: 0,
                            dirsToCreate: [URL](),
                            filesToCopy: [URLPair](),
                            filesToCopySize: 0,
                            filesToOverwrite: [URLPair](),
                            filesToOverwriteSize: 0,
                            filesToDownloadAndCopy: [URLPair](),
                            filesToDownloadAndCopySize: 0,
                            filesToDownloadAndOverwrite: [URLPair](),
                            filesToDownloadAndOverwriteSize: 0,
                            filesToDeleteBanlist: [URL](),
                            filesToDeleteBanlistSize: 0)
    
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: srcURL.path) else {
        print("Directory not found")
        return stats
    }
    
    while let element = enumerator.nextObject() as? String {
        // Build URL that this element has at src
        var srcElementURL: URL = URL(fileURLWithPath: srcURL.path)
        srcElementURL.appendPathComponent(element)
        
        // Build URL that this element would have if it exists at dst
        var dstElementURL: URL = URL(fileURLWithPath: dstURL.path)
        dstElementURL.appendPathComponent(element)
        
        if let values = try? srcElementURL.resourceValues(forKeys: [.isDirectoryKey]),
           let isDirectory = values.isDirectory {
            if isDirectory {
                stats.dirCount += 1
                
                var isDir: ObjCBool = true
                if !fileManager.fileExists(atPath: dstElementURL.path, isDirectory:&isDir) {
                    stats.dirsToCreate.append(dstElementURL)
                }
            } else {
                stats.fileCount += 1
                var isDir: ObjCBool = false
                
                if fileIsPlaceholder(url: srcElementURL) {
                    let offladedName = getNameOfOffloadedContent(url: srcElementURL)

                    // If the real name can't be read from the placeholder plist, the URLs
                    // below would collapse to the parent directory (appendPathComponent("")
                    // is a no-op). Skip the file instead of queueing a directory for copy.
                    if offladedName.isEmpty {
                        print("Skipping (could not read offloaded name): \(srcElementURL.path)")
                        continue
                    }

                    var realSrcElementURL = srcElementURL.deletingLastPathComponent()
                    realSrcElementURL.appendPathComponent(offladedName)
                    
                    var realDstElementURL = dstElementURL.deletingLastPathComponent()
                    realDstElementURL.appendPathComponent(offladedName)
                    
                    let offloadedSize = getSizeOfOffloadedContent(url: srcElementURL)
                    
                    if fileManager.fileExists(atPath: realDstElementURL.path, isDirectory:&isDir) {
                        do {
                            let placeholderAttr = try fileManager.attributesOfItem(atPath: srcElementURL.path)
                            let dstAttr = try fileManager.attributesOfItem(atPath: realDstElementURL.path)

                            // Read attributes as optionals so a missing date/size never traps.
                            // If any can't be read we fall through to download & copy below.
                            if let placeholderCreationDate = placeholderAttr[FileAttributeKey.creationDate] as? Date,
                               let placeholderModificationDate = placeholderAttr[FileAttributeKey.modificationDate] as? Date,
                               let dstFileSize = (dstAttr[FileAttributeKey.size] as? NSNumber)?.int64Value,
                               let dstCreationDate = dstAttr[FileAttributeKey.creationDate] as? Date,
                               let dstModificationDate = dstAttr[FileAttributeKey.modificationDate] as? Date {
                                let oneSecond: TimeInterval = 1.0
                                let creationDateOffset = abs(placeholderCreationDate - dstCreationDate)
                                let modificationDateOffset = abs(placeholderModificationDate - dstModificationDate)

                                if offloadedSize == dstFileSize
                                    && creationDateOffset < oneSecond
                                    && modificationDateOffset < oneSecond {
                                    // Backup already matches the offloaded file, nothing to do.
                                    continue
                                }

                                // Exists at dst but differs in size and/or timestamps: download and
                                // overwrite, since copying onto an existing file would fail.
                                stats.filesToDownloadAndOverwrite.append(URLPair(placeholder: srcElementURL,
                                                                                 src: realSrcElementURL,
                                                                                 dst: realDstElementURL))
                                stats.filesToDownloadAndOverwriteSize += offloadedSize
                                continue
                            }
                        } catch {
                            // Something happened when accessing file attributes of either src or dst.
                            // Did not see this yet. Unclear how to proceed.
                            print(error.localizedDescription)
                        }
                    }
                    
                    stats.filesToDownloadAndCopy.append(URLPair(placeholder: srcElementURL,
                                                                src: realSrcElementURL,
                                                                dst: realDstElementURL))
                    stats.filesToDownloadAndCopySize += offloadedSize
                    continue
                }

                let fileSize: Int64 = fileManager.fileSize(atPath: srcElementURL.path) ?? 0
                stats.fileSize += fileSize
                
                // Banlist 1/1: File is .DS_Store
                if srcElementURL.lastPathComponent == ".DS_Store" {
                    stats.filesToDeleteBanlist.append(srcElementURL)
                    stats.filesToDeleteBanlistSize += fileSize
                    continue
                }
                
                if fileManager.fileExists(atPath: dstElementURL.path, isDirectory:&isDir) {
                    do {
                        let srcAttr = try fileManager.attributesOfItem(atPath: srcElementURL.path)
                        let dstAttr = try fileManager.attributesOfItem(atPath: dstElementURL.path)

                        // Read attributes as optionals so a missing date/size never traps.
                        // If any can't be read we fall through to copy below.
                        if let srcFileSize = (srcAttr[FileAttributeKey.size] as? NSNumber)?.int64Value,
                           let srcCreationDate = srcAttr[FileAttributeKey.creationDate] as? Date,
                           let srcModificationDate = srcAttr[FileAttributeKey.modificationDate] as? Date,
                           let dstFileSize = (dstAttr[FileAttributeKey.size] as? NSNumber)?.int64Value,
                           let dstCreationDate = dstAttr[FileAttributeKey.creationDate] as? Date,
                           let dstModificationDate = dstAttr[FileAttributeKey.modificationDate] as? Date {
                            let oneSecond: TimeInterval = 1.0
                            let creationDateOffset = abs(srcCreationDate - dstCreationDate)
                            let modificationDateOffset = abs(srcModificationDate - dstModificationDate)

                            if srcFileSize == dstFileSize
                                && creationDateOffset < oneSecond
                                && modificationDateOffset < oneSecond {
                                // Identical at src and dst, nothing to do.
                                continue
                            }

                            // Exists at dst but differs in size and/or timestamps: overwrite in
                            // place, since copying onto an existing file would fail.
                            stats.filesToOverwrite.append(URLPair(src: srcElementURL,
                                                                  dst: dstElementURL))
                            stats.filesToOverwriteSize += fileSize
                            continue
                        }
                    } catch {
                        // Something happened when accessing file attributes of either src or dst.
                        // Did not see this yet. Unclear how to proceed.
                        print(error.localizedDescription)
                    }
                }
                
                stats.filesToCopy.append(URLPair(src: srcElementURL,
                                                 dst: dstElementURL))
                stats.filesToCopySize += fileSize
            }
        }
    }

    stats.end = Date()
    return stats
}
