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
