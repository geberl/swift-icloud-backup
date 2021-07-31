import Foundation

func getSizeString(byteCount: Int64) -> String {
    let unit: String = "all"
    
    if byteCount == 0 {
        if unit == "all" {
            return "0 bytes"
        }
        return "0 " + unit
    }
    
    let byteCountFormatter = ByteCountFormatter()
    if unit == "bytes" {
        byteCountFormatter.allowedUnits = .useBytes
    } else if unit == "KB" {
        byteCountFormatter.allowedUnits = .useKB
    } else if unit == "MB" {
        byteCountFormatter.allowedUnits = .useMB
    } else if unit == "GB" {
        byteCountFormatter.allowedUnits = .useGB
    } else {
        byteCountFormatter.allowedUnits = .useAll
    }
    byteCountFormatter.countStyle = .file
    
    return byteCountFormatter.string(fromByteCount: byteCount)
}

func printDstStats(stats: dstDirStats, verbose: Bool) {
    print("Results destination dir ----------------------------------")
    print("  start                         ", stats.start)
    print("  end                           ", stats.end ?? "n/a")
    print("  directories                   ", stats.dirCount)
    print(String(format: "  files                          %d (%@)", stats.fileCount, getSizeString(byteCount: stats.fileSize)))
    print("  directories to delete         ", stats.dirsToDelete.count)
    if verbose {
        for item in stats.dirsToDelete {
            print("    ", item.path)
        }
    }
    print(String(format: "  files to delete                %d (%@)", stats.filesToDelete.count, getSizeString(byteCount: stats.filesToDeleteSize)))
    if verbose {
        for item in stats.filesToDelete {
            print("    ", item.path)
        }
    }
    print(String(format: "  files to delete (banlist)      %d (%@)", stats.filesToDeleteBanlist.count, getSizeString(byteCount: stats.filesToDeleteBanlistSize)))
    if verbose {
        for item in stats.filesToDeleteBanlist {
            print("    ", item.path)
        }
    }
    print("")
}

func printSrcStats(stats: srcDirStats, verbose: Bool) {
    print("Results source dir ---------------------------------------")
    print("  start                         ", stats.start)
    print("  end                           ", stats.end ?? "n/a")
    print("  directories                   ", stats.dirCount)
    print("  files                         ", stats.fileCount)
    print("  size                          ", getSizeString(byteCount: stats.fileSize))
    print("  directories to create         ", stats.dirsToCreate.count)
    if verbose {
        for item in stats.dirsToCreate {
            print("    ", item.path)
        }
    }
    print(String(format: "  files to copy                  %d (%@)", stats.filesToCopy.count, getSizeString(byteCount: stats.filesToCopySize)))
    if verbose {
        for item in stats.filesToCopy {
            print("    ", item.src.path)
        }
    }
    print(String(format: "  files to overwrite             %d (%@)", stats.filesToOverwrite.count, getSizeString(byteCount: stats.filesToOverwriteSize)))
    if verbose {
        for item in stats.filesToOverwrite {
            print("    ", item.src.path)
        }
    }
    print(String(format: "  files to download & copy       %d (%@)", stats.filesToDownloadAndCopy.count, getSizeString(byteCount: stats.filesToDownloadAndCopySize)))
    if verbose {
        for item in stats.filesToDownloadAndCopy {
            print("    ", item.src.path)
        }
    }
    print(String(format: "  files to download & overwrite  %d (%@)", stats.filesToDownloadAndOverwrite.count, getSizeString(byteCount: stats.filesToDownloadAndOverwriteSize)))
    if verbose {
        for item in stats.filesToDownloadAndOverwrite {
            print("    ", item.src.path)
        }
    }
    print(String(format: "  files to delete (banlist)      %d (%@)", stats.filesToDeleteBanlist.count, getSizeString(byteCount: stats.filesToDeleteBanlistSize)))
    if verbose {
        for item in stats.filesToDeleteBanlist {
            print("    ", item.path)
        }
    }
    print("")
}
