//
//  main.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation
import ArgumentParser

struct CloudStatsOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.") var version = false
    @Flag(name: .long, help: "Show auto-detected source path and exit.") var showSrc = false
    @Option(help: ArgumentHelp("Override the source path.", valueName: "path")) var src = ""
    // --help is automatically included
}

let options = CloudStatsOptions.parseOrExit()

if options.version == true {
    print("Version 1.0.0")
} else if options.showSrc == true {
    let documentsUrl = try FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
    print(documentsUrl.path.deletingPrefix("file://"))
} else {
    var scanUrl: URL?
    let fileManager = FileManager.default
    
    if options.src != "" {
        var isDir : ObjCBool = true
        if fileManager.fileExists(atPath: options.src, isDirectory:&isDir) {
            scanUrl = URL(string: options.src)
        } else {
            print("Source path does not exist")
            exit(1)
        }
    } else {
        do {
            scanUrl = try FileManager.default.url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: false)
        } catch {
            print(error.localizedDescription)
            exit(1)
        }
    }
    
    if let safeScanUrl = scanUrl {
        let childDirs = getChildDirs(url: safeScanUrl)
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
        
        printStats(overall: overall)
    }
}
