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

func getDurationAndTimes(from: Date, to: Date?) -> String{
    let durationFormatter = DateComponentsFormatter()
    durationFormatter.unitsStyle = .abbreviated
    durationFormatter.zeroFormattingBehavior = .dropAll
    durationFormatter.allowedUnits = [.minute, .second]
    
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .iso8601)
    dateFormatter.locale = Locale(identifier: TimeZone.current.identifier)
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = "HH:mm:ss"
    
    var output: String = ""
    if let safeTo = to {
        if let safeDurationString = durationFormatter.string(from: safeTo - from) {
            output += safeDurationString
        } else {
            output += "?"
        }
        output += " (" + dateFormatter.string(from: from) + " - " + dateFormatter.string(from: safeTo) + ")"
    } else {
        output += "? (" + dateFormatter.string(from: from) + " - n/a)"
    }
    return output
}

func printDstStats(stats: dstDirStats, verbose: Bool) {
    let inset = String("  ")
    let firstColSize = 40
    let secondColSize = 38
    
    var output: String = ""
    output += String("Results destination dir ").rPad(toLength: firstColSize + secondColSize, withPad: "-") + "\n"
    output += inset + String("analysis duration").rPad(toLength: firstColSize, withPad: " ") + getDurationAndTimes(from: stats.start, to: stats.end) + "\n"
    output += inset + String("directories").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d", stats.dirCount) + "\n"
    output += inset + String("files").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.fileCount, getSizeString(byteCount: stats.fileSize)) + "\n"
    output += inset + String("directories to delete").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d", stats.dirsToDelete.count) + "\n"
    if verbose {
        for item in stats.dirsToDelete {
            output += inset + inset + item.path + "\n"
        }
    }
    output += inset + String("files to delete").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToDelete.count, getSizeString(byteCount: stats.filesToDeleteSize)) + "\n"
    if verbose {
        for item in stats.filesToDelete {
            output += inset + inset + item.path + "\n"
        }
    }
    output += inset + String("files to delete (banlist)").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToDeleteBanlist.count, getSizeString(byteCount: stats.filesToDeleteBanlistSize)) + "\n"
    if verbose {
        for item in stats.filesToDeleteBanlist {
            output += inset + inset + item.path + "\n"
        }
    }
    
    print(output)
}

func printSrcStats(stats: srcDirStats, verbose: Bool) {
    let inset = String("  ")
    let firstColSize = 40
    let secondColSize = 38
    
    var output: String = ""
    output += String("Results source dir ").rPad(toLength: firstColSize + secondColSize, withPad: "-") + "\n"
    output += inset + String("analysis duration").rPad(toLength: firstColSize, withPad: " ") + getDurationAndTimes(from: stats.start, to: stats.end) + "\n"
    output += inset + String("directories").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d", stats.dirCount) + "\n"
    output += inset + String("files").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.fileCount, getSizeString(byteCount: stats.fileSize)) + "\n"
    output += inset + String("directories to create").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d", stats.dirsToCreate.count) + "\n"
    if verbose {
        for item in stats.dirsToCreate {
            output += inset + inset + item.path + "\n"
        }
    }
    output += inset + String("files to copy").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToCopy.count, getSizeString(byteCount: stats.filesToCopySize)) + "\n"
    if verbose {
        for item in stats.filesToCopy {
            output += inset + inset + item.src.path + "\n"
        }
    }
    output += inset + String("files to overwrite").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToOverwrite.count, getSizeString(byteCount: stats.filesToOverwriteSize)) + "\n"
    if verbose {
        for item in stats.filesToOverwrite {
            output += inset + inset + item.src.path + "\n"
        }
    }
    output += inset + String("files to download & copy").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToDownloadAndCopy.count, getSizeString(byteCount: stats.filesToDownloadAndCopySize)) + "\n"
    if verbose {
        for item in stats.filesToDownloadAndCopy {
            output += inset + inset + item.src.path + "\n"
        }
    }
    output += inset + String("files to download & overwrite").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToDownloadAndOverwrite.count, getSizeString(byteCount: stats.filesToDownloadAndOverwriteSize)) + "\n"
    if verbose {
        for item in stats.filesToDownloadAndOverwrite {
            output += inset + inset + item.src.path + "\n"
        }
    }
    output += inset + String("files to delete (banlist)").rPad(toLength: firstColSize, withPad: " ") + String(format: "%d (%@)", stats.filesToDeleteBanlist.count, getSizeString(byteCount: stats.filesToDeleteBanlistSize)) + "\n"
    if verbose {
        for item in stats.filesToDeleteBanlist {
            output += inset + inset + item.path + "\n"
        }
    }
    
    print(output)
}
