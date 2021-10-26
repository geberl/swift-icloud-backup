import Foundation

enum ArgumentError: Error {
    case DestinationUnset
    case DestinationDoesNotExist
    case SourceDoesNotExist
}

struct CLI {
    private let options: IcloudbackupOptions
    private let version: String
    
    init(options: IcloudbackupOptions, version: String) {
        self.options = options
        self.version = version
    }
    
    func run() throws {
        if options.version == true {
            print("Version " + self.version)
            return
        }
        
        if options.showSrc == true {
            let documentsUrl = try FileManager.default.url(for: .documentDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
            print(documentsUrl.path.deletingPrefix("file://"))
            return
        }
        
        var srcUrl: URL?
        var dstUrl: URL?
        let fileManager = FileManager.default
        
        if options.dst == "" {
            throw ArgumentError.DestinationUnset
        } else {
            var isDir: ObjCBool = ObjCBool(true)
            if fileManager.fileExists(atPath: options.dst, isDirectory: &isDir) {
                dstUrl = URL(fileURLWithPath: options.dst)
            } else {
                throw ArgumentError.DestinationDoesNotExist
            }
        }
        
        if options.src == "" {
            try srcUrl = FileManager.default.url(for: .documentDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: false)
        } else {
            if fileManager.dirExists(atPath: options.src) {
                srcUrl = URL(fileURLWithPath: options.src)
            } else {
                throw ArgumentError.SourceDoesNotExist
            }
        }
        
        if let safeDstUrl = dstUrl {
            if let safeSrcUrl = srcUrl {
                let dstStats = analyzeDstDir(dstURL: safeDstUrl, srcURL: safeSrcUrl)
                printDstStats(stats: dstStats, verbose: options.verbose)
                
                let srcStats = analyzeSrcDir(srcURL: safeSrcUrl, dstURL: safeDstUrl)
                printSrcStats(stats: srcStats, verbose: options.verbose)
                
                if !options.dryRun {
                    DeleteItems(items: srcStats.filesToDeleteBanlist)
                    DeleteItems(items: dstStats.filesToDeleteBanlist)
                    DeleteItems(items: dstStats.filesToDelete)
                    DeleteItems(items: dstStats.dirsToDelete)
                    CreateDirs(dirs: srcStats.dirsToCreate)
                    CopyFiles(files: srcStats.filesToCopy)
                    OverwriteFiles(files: srcStats.filesToOverwrite)
                    DownloadAndCopyFiles(files: srcStats.filesToDownloadAndCopy)
                    DownloadAndOverwriteFiles(files: srcStats.filesToDownloadAndOverwrite)
                }
            }
        }
    }
}
