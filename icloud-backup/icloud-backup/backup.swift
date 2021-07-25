//
//  backup.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-24.
//

import Foundation
import Progress

func DeleteItems(items: [URL]) {
    for item in items {
        if FileManager.default.fileExists(atPath: item.path) {
            do {
                try FileManager.default.removeItem(at: item)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

func CreateDirs(dirs: [URL]) {
    for dir in dirs {
        if !FileManager.default.fileExists(atPath: dir.path) {
            do {
                try FileManager.default.createDirectory(atPath: dir.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

func CopyFiles(files: [URLPair]) {
    for file in files {
        do {
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func OverwriteFiles(files: [URLPair]) {
    for file in files {
        do {
            try FileManager.default.removeItem(at: file.dst)
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func DownloadAndCopyFiles(files: [URLPair]) {
    for file in Progress(files) {
        do {
            try DownloadFromCloud(placeholder: file.placeholder!, file: file.src)
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
            try FileManager.default.evictUbiquitousItem(at: file.src)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func DownloadFromCloud(placeholder: URL, file: URL) throws {
    try FileManager.default.startDownloadingUbiquitousItem(at: placeholder)
    do {
        let attributes = try placeholder.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
        if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
            if status == URLUbiquitousItemDownloadingStatus.current {
                return
            } else if status == URLUbiquitousItemDownloadingStatus.downloaded {
                return
            } else if status == URLUbiquitousItemDownloadingStatus.notDownloaded {
                sleep(1)
                try DownloadFromCloud(placeholder: placeholder, file: file)
            }
        }
    } catch {
        // Very crude
    }
}
