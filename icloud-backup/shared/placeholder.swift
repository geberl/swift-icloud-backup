import Foundation

struct iCloudPlist: Codable {
    var NSURLFileResourceTypeKey: String
    var NSURLFileSizeKey: Int64
    var NSURLNameKey: String
}

func fileIsPlaceholder(url: URL) -> Bool {
    if let fileType: String = url.typeIdentifier {
        if fileType == "com.apple.icloud-file-fault" {
            return true
        }
    }
    return false
}

func getSizeOfOffloadedContent(url: URL) -> Int64 {
    guard let xml = FileManager.default.contents(atPath: url.path) else {
        print(url)
        return 0
    }
  
    if let plist = try? PropertyListDecoder().decode(iCloudPlist.self, from: xml) {
        return plist.NSURLFileSizeKey
    }
    return 0
}

func getNameOfOffloadedContent(url: URL) -> String {
    guard let xml = FileManager.default.contents(atPath: url.path) else {
        print(url)
        return ""
    }
  
    if let plist = try? PropertyListDecoder().decode(iCloudPlist.self, from: xml) {
        return plist.NSURLNameKey
    }
    return ""
}

func correspondingFileURL(placeholderURL: URL) -> URL {
    // Input url = placeholder, output url = real file
    var outURL: URL = placeholderURL.deletingLastPathComponent()
    outURL.appendPathComponent(getNameOfOffloadedContent(url: placeholderURL))
    return outURL
}

func correspondingPlaceholderURL(fileURL: URL) -> URL {
    // Input url = real file, output = placeholder
    var outURL: URL = fileURL.deletingLastPathComponent()
    outURL.appendPathComponent("." + fileURL.lastPathComponent + ".icloud")
    return outURL
}
