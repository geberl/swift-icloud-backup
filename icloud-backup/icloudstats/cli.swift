import Foundation

enum ArgumentError: Error {
    case SourceDoesNotExist
}

struct CLI {
    private let options: IcloudstatsOptions
    private let version: String
    
    init(options: IcloudstatsOptions, version: String) {
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
        let fileManager = FileManager.default
        
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
        
        if let safeSrcUrl = srcUrl {
            let srcStats = analyzeSrcDir(srcURL: safeSrcUrl)
            printSrcStats(overall: srcStats)
        }
    }
}
