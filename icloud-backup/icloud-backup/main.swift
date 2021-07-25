//
//  main.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation
import ArgumentParser

struct CloudBackupOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.") var version = false
    @Flag(name: .long, help: "Show auto-detected source path and exit.") var showSrc = false
    @Flag(name: .long, help: "Analyze source and destination and print what would happen.") var dryRun = false
    @Flag(name: .long, help: "Show the paths of individual items after analyzing source and destination.") var verbose = false
    @Option(help: ArgumentHelp("Override the source path.", valueName: "path")) var src = ""
    @Option(help: ArgumentHelp("Set the destination path.", valueName: "path")) var dst = ""
    // --help is automatically included
}

let options = CloudBackupOptions.parseOrExit()

if options.version == true {
    print("Version 1.0.0")
} else if options.showSrc == true {
    let documentsUrl = try FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
    print(documentsUrl.path.deletingPrefix("file://"))
} else {
    var srcUrl: URL?
    var dstUrl: URL?
    let fileManager = FileManager.default
    var isDir : ObjCBool = true
    
    if options.dst == "" {
        print("Destination path must be set.")
        exit(1)
    } else {
        if fileManager.fileExists(atPath: options.dst, isDirectory:&isDir) {
            dstUrl = URL(fileURLWithPath: options.dst)
        } else {
            print("Destination path does not exist")
            exit(1)
        }
    }
    
    if options.src == "" {
        do {
            srcUrl = try FileManager.default.url(for: .documentDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: false)
        } catch {
            print(error.localizedDescription)
            exit(1)
        }
    } else {
        if fileManager.fileExists(atPath: options.src, isDirectory:&isDir) {
            srcUrl = URL(fileURLWithPath: options.src)
        } else {
            print("Source path does not exist")
            exit(1)
        }
    }
    
    if let safeDstUrl = dstUrl {
        if let safeSrcUrl = srcUrl {
            let dstStats = analyzeDstDir(dstURL: safeDstUrl, srcURL: safeSrcUrl)
            printDstStats(stats: dstStats, verbose: options.verbose)
            
            let srcStats = analyzeSrcDir(srcURL: safeSrcUrl, dstURL: safeDstUrl)
            printSrcStats(stats: srcStats, verbose: options.verbose)
            
            if options.dryRun == true {
                exit(0)
            } else {
                DeleteItems(items: srcStats.filesToDeleteBanlist)
                DeleteItems(items: dstStats.filesToDeleteBanlist)
                DeleteItems(items: dstStats.filesToDelete)
                DeleteItems(items: dstStats.dirsToDelete)
                
                CreateDirs(dirs: srcStats.dirsToCreate)
                CopyFiles(files: srcStats.filesToCopy)
                DownloadAndCopyFiles(files: srcStats.filesToDownloadAndCopy)
            }
        }
    }
}

struct URLPair {
    var placeholder: URL?
    var src: URL
    var dst: URL
}
