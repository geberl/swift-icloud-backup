//
//  placeholder.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation

struct iCloudPlist: Codable {
    var NSURLFileResourceTypeKey: String
    var NSURLFileSizeKey: Int64
    var NSURLNameKey: String
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
