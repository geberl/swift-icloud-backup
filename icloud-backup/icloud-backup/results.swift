//
//  results.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation

func printStats(overall: dirOverall) {
    printHeadline(overall: overall)
    
    for stats in overall.stats {
        printDirStats(overall: overall, stats: stats)
    }
    
    printTotalStats(overall: overall)
    
    print("")
}

func printHeadline(overall: dirOverall) {
    var headline: String = ""
    headline += "PATH".rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    headline += "DIRS".rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    headline += "FILES".rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    headline += "PLACEHOLDERS".rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    headline += "HIDDEN".rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    headline += "SIZE".rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    headline += "OFFLOADED".rPad(toLength: overall.maxLengthSizeOffloaded + 3, withPad: " ")
    headline += "TOTAL".rPad(toLength: overall.maxLengthTotal + 6, withPad: " ")
    headline += "PERCENT"
    print(headline)
}

func printDirStats(overall: dirOverall, stats: dirStats) {
    var pathInfo: String = ""
    pathInfo += stats.path.rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    pathInfo += String(stats.numberOfDirs).rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    pathInfo += String(stats.numberOfFiles).rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    pathInfo += String(stats.numberOfPlaceholders).rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    pathInfo += String(stats.numberOfHidden).rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeFiles).rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeOffloaded).rPad(toLength: overall.maxLengthSizeOffloaded + 3, withPad: " ")
    pathInfo += getSizeString(byteCount: stats.sizeFiles + stats.sizeOffloaded).rPad(toLength: overall.maxLengthTotal + 6, withPad: " ")
    pathInfo += getPercentString(bytesDir: stats.sizeFiles + stats.sizeOffloaded, bytesTotal: overall.totalSizeFiles + overall.totalSizeOffloaded)
    print(pathInfo)
}

func printTotalStats(overall: dirOverall) {
    var total: String = "\n"
    total += "TOTAL".rPad(toLength: overall.maxLengthPath + 3, withPad: " ")
    total += String(overall.totalDirs).rPad(toLength: overall.maxLengthDirs + 3, withPad: " ")
    total += String(overall.totalFiles).rPad(toLength: overall.maxLengthFiles + 3, withPad: " ")
    total += String(overall.totalPlaceholders).rPad(toLength: overall.maxLengthPlaceholders + 3, withPad: " ")
    total += String(overall.totalHidden).rPad(toLength: overall.maxLengthHidden + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeFiles).rPad(toLength: overall.maxLengthSizeFiles + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeOffloaded).rPad(toLength: overall.maxLengthSizeOffloaded + 3, withPad: " ")
    total += getSizeString(byteCount: overall.totalSizeFiles + overall.totalSizeOffloaded).rPad(toLength: overall.maxLengthTotal + 6, withPad: " ")
    total += "100.0"
    print(total)
}

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

func getPercentString(bytesDir: Int64, bytesTotal: Int64) -> String {
    let percent = ( Float(bytesDir) / Float(bytesTotal) ) * 100
    return String(format: "%2.1f", arguments: [percent])
}
