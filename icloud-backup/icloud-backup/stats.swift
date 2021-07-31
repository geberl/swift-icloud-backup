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
    print("  files                         ", stats.fileCount)
    print("  size                          ", getSizeString(byteCount: stats.fileSize))
    print("  directories to delete         ", stats.dirsToDelete.count)
    if verbose {
        for item in stats.dirsToDelete {
            print("    ", item.path)
        }
    }
    print("  files to delete               ", stats.filesToDelete.count)
    if verbose {
        for item in stats.filesToDelete {
            print("    ", item.path)
        }
    }
    print("  size (delete)                 ", getSizeString(byteCount: stats.filesToDeleteSize))
    print("  files to delete (banlist)     ", stats.filesToDeleteBanlist.count)
    if verbose {
        for item in stats.filesToDeleteBanlist {
            print("    ", item.path)
        }
    }
    print("  size (banlist)                ", getSizeString(byteCount: stats.filesToDeleteBanlistSize))
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
    print("  files to copy                 ", stats.filesToCopy.count)
    if verbose {
        for item in stats.filesToCopy {
            print("    ", item.src.path)
        }
    }
    print("  size (copy)                   ", getSizeString(byteCount: stats.filesToCopySize))
    print("  files to overwrite            ", stats.filesToOverwrite.count)
    if verbose {
        for item in stats.filesToOverwrite {
            print("    ", item.src.path)
        }
    }
    print("  size (overwrite)              ", getSizeString(byteCount: stats.filesToOverwriteSize))
    print("  files to download & copy      ", stats.filesToDownloadAndCopy.count)
    if verbose {
        for item in stats.filesToDownloadAndCopy {
            print("    ", item.src.path)
        }
    }
    print("  size (download & copy)        ", getSizeString(byteCount: stats.filesToDownloadAndCopySize))
    print("  files to download & overwrite ", stats.filesToDownloadAndOverwrite.count)
    if verbose {
        for item in stats.filesToDownloadAndOverwrite {
            print("    ", item.src.path)
        }
    }
    print("  size (download & overwrite)   ", getSizeString(byteCount: stats.filesToDownloadAndOverwriteSize))
    print("  files to delete (banlist)     ", stats.filesToDeleteBanlist.count)
    if verbose {
        for item in stats.filesToDeleteBanlist {
            print("    ", item.path)
        }
    }
    print("  size (banlist)                ", getSizeString(byteCount: stats.filesToDeleteBanlistSize))
    print("")
}
