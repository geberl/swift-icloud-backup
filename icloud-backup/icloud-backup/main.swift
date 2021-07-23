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
            
            print("Results destination dir -----------------------------")
            print(" start                     ", dstStats.start)
            print(" end                       ", dstStats.end ?? "n/a")
            print(" directories               ", dstStats.dirCount)
            print(" files                     ", dstStats.fileCount)
            print(" size                      ", getSizeString(byteCount: dstStats.fileSize))
            print(" directories to delete     ", dstStats.dirsToDelete.count)
            print(" files to delete           ", dstStats.filesToDelete.count)
            print(" size (delete)             ", getSizeString(byteCount: dstStats.filesToDeleteSize))
            print(" files to delete (banlist) ", dstStats.filesToDeleteBanlist.count)
            print(" size (banlist)            ", getSizeString(byteCount: dstStats.filesToDeleteBanlistSize))
            print("")
            
            let srcStats = analyzeSrcDir(srcURL: safeSrcUrl, dstURL: safeDstUrl)

            print("Results source dir ----------------------------------")
            print(" start                     ", srcStats.start)
            print(" end                       ", srcStats.end ?? "n/a")
            print(" directories               ", srcStats.dirCount)
            print(" files                     ", srcStats.fileCount)
            print(" size                      ", getSizeString(byteCount: srcStats.fileSize))
            print(" directories to create     ", srcStats.dirsToCreate.count)
            print(" files to copy             ", srcStats.filesToCopy.count)
            print(" size (copy)               ", getSizeString(byteCount: srcStats.filesToCopySize))
            print(" files to download & copy  ", srcStats.filesToDownloadAndCopy.count)
            print(" size (download & copy)    ", getSizeString(byteCount: srcStats.filesToDownloadAndCopySize))
            print("")
        }
    }
    
    if options.dryRun == true {
        exit(0)
    } else {
        // TODO, in this order:
        
        // dstDeleteFilesBanlist()
        // dstDeleteFiles()
        // dstDeleteDirs()
        
        // srcCreateDirs()
        // srcCopyFiles()
        // srcDownloadAndCopyFiles()
    }
}
