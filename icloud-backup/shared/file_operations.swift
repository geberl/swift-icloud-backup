import Foundation

struct URLPair {
    var placeholder: URL?
    var src: URL
    var dst: URL
}

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
    for file in files {
        WaitDownloadFromCloud(placeholder: file.placeholder!, file: file.src)
        do {
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
            try FileManager.default.evictUbiquitousItem(at: file.src)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func DownloadAndOverwriteFiles(files: [URLPair]) {
    for file in files {
        WaitDownloadFromCloud(placeholder: file.placeholder!, file: file.src)
        do {
            try FileManager.default.removeItem(at: file.dst)
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
            try FileManager.default.evictUbiquitousItem(at: file.src)
        } catch {
            print(error.localizedDescription)
        }
    }
}

func WaitDownloadFromCloud(placeholder: URL, file: URL) {
    // TODO this whole function is very crude, rewrite
    // I did not manage to subscribe to the correct notifications, never received anything when doing like that:
    // https://github.com/MixinNetwork/ios-app/blob/e516175e62e245af21d6d15f703fa607f3ed76ad/Mixin/UserInterface/Controllers/Home/RestoreViewController.swift#L110
    // https://stackoverflow.com/questions/42457929/is-it-icloud-or-is-it-my-code
    // https://stackoverflow.com/questions/43325561/turning-off-icloud-and-remove-items-from-the-ubiquitous-container/43328488#43328488
    // https://stackoverflow.com/questions/51843828/how-to-get-data-from-a-file-in-icloud-after-reinstalling-the-app
    
    do {
        try FileManager.default.startDownloadingUbiquitousItem(at: placeholder)
        let attributes = try placeholder.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
        if let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus {
            if status == URLUbiquitousItemDownloadingStatus.current {
                return
            } else if status == URLUbiquitousItemDownloadingStatus.downloaded {
                return
            } else if status == URLUbiquitousItemDownloadingStatus.notDownloaded {
                sleep(1)
                WaitDownloadFromCloud(placeholder: placeholder, file: file)
            }
        }
    } catch {
        print(error.localizedDescription)
    }
}

func TriggerDownloadFromCloud(placeholder: URL) {
    do {
        try FileManager.default.startDownloadingUbiquitousItem(at: placeholder)
    } catch {
        print(error.localizedDescription)
    }
}

func TriggerOffloadToCloud(file: URL) {
    do {
        try FileManager.default.evictUbiquitousItem(at: file)
    } catch {
        print(error.localizedDescription)
    }
}
