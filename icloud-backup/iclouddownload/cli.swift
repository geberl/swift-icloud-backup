import Foundation

enum ArgumentError: Error {
    case BaseUnset
    case BaseDoesNotExist
}

struct CLI {
    private let options: IclouddownloadOptions
    private let version: String
    
    init(options: IclouddownloadOptions, version: String) {
        self.options = options
        self.version = version
    }
    
    func run() throws {
        if options.version == true {
            print("Version " + self.version)
            return
        }
        
        var baseUrl: URL?
        let fileManager = FileManager.default
        
        if options.base == "" {
            throw ArgumentError.BaseUnset
        } else {
            if fileManager.dirExists(atPath: options.base) {
                baseUrl = URL(fileURLWithPath: options.base)
            } else {
                throw ArgumentError.BaseDoesNotExist
            }
        }

        if let safeBaseUrl = baseUrl {
            DownloadItems(baseURL: safeBaseUrl, verbose: options.verbose)
        }
    }
}
