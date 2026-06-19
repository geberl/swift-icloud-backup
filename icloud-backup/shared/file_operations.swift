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
        guard WaitDownloadFromCloud(placeholder: file.placeholder!, file: file.src) else {
            print("Skipping (download failed): \(file.src.path)")
            continue
        }
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
        guard WaitDownloadFromCloud(placeholder: file.placeholder!, file: file.src) else {
            print("Skipping (download failed): \(file.src.path)")
            continue
        }
        do {
            try FileManager.default.removeItem(at: file.dst)
            try FileManager.default.copyItem(atPath: file.src.path, toPath: file.dst.path)
            try FileManager.default.evictUbiquitousItem(at: file.src)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// Kicks off the download of an offloaded item and blocks until it is local.
// Returns true once the file is downloaded, false if the download errors out or
// makes no progress within `timeout` seconds. Polls instead of recursing so the
// wait is bounded and the stack can't grow with the download duration.
//
// Note on the notification-free polling approach: subscribing to the relevant
// iCloud notifications never delivered anything in practice, so we poll the
// item's downloading status. See:
// https://stackoverflow.com/questions/42457929/is-it-icloud-or-is-it-my-code
// https://stackoverflow.com/questions/43325561/turning-off-icloud-and-remove-items-from-the-ubiquitous-container/43328488#43328488
@discardableResult
func WaitDownloadFromCloud(placeholder: URL, file: URL, timeout: TimeInterval = 3600) -> Bool {
    let fileManager = FileManager.default

    do {
        try fileManager.startDownloadingUbiquitousItem(at: placeholder)
    } catch {
        print(error.localizedDescription)
        return false
    }

    let start = Date()
    while Date() - start < timeout {
        if let status = downloadingStatus(of: placeholder) {
            if status == .current || status == .downloaded {
                return true
            }
            // status == .notDownloaded: keep waiting.
        } else if fileManager.fileExists(atPath: file.path) {
            // The status is no longer readable on the placeholder path because the
            // finished download replaced it with the real file. Treat as success.
            return true
        }
        sleep(1)
    }

    print("Timed out after \(Int(timeout))s waiting for iCloud download: \(file.path)")
    return false
}

// Reads the iCloud downloading status from a freshly built URL so the value is
// never served from URL's resource-value cache. Returns nil when the status
// can't be read (e.g. the placeholder no longer exists).
private func downloadingStatus(of placeholder: URL) -> URLUbiquitousItemDownloadingStatus? {
    let freshURL = URL(fileURLWithPath: placeholder.path)
    guard let values = try? freshURL.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey]) else {
        return nil
    }
    return values.ubiquitousItemDownloadingStatus
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
