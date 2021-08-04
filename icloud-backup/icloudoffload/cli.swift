import Foundation

enum ArgumentError: Error {
    case BaseUnset
    case BaseDoesNotExist
}

struct CLI {
    private let options: IcloudoffloadOptions
    private let version: String
    
    init(options: IcloudoffloadOptions, version: String) {
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
        var isDir : ObjCBool = true
        
        if options.base == "" {
            throw ArgumentError.BaseUnset
        } else {
            if fileManager.fileExists(atPath: options.base, isDirectory: &isDir) {
                baseUrl = URL(fileURLWithPath: options.base)
            } else {
                throw ArgumentError.BaseDoesNotExist
            }
        }

        if let safeBaseUrl = baseUrl {
            OffloadItems(baseURL: safeBaseUrl, verbose: options.verbose)
        }
    }
}
