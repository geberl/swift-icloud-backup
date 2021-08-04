import Foundation

func DownloadItems(baseURL: URL, verbose: Bool) {
    let fileManager = FileManager.default
    guard let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: baseURL.path) else {
        print("Directory not found")
        return
    }
    
    while let element = enumerator.nextObject() as? String {
        // Build the URL that the currently iterated over element has
        var elementURL: URL = URL(fileURLWithPath: baseURL.path)
        elementURL.appendPathComponent(element)
        
        if let values = try? elementURL.resourceValues(forKeys: [.isDirectoryKey]) {
            if values.isDirectory! {
                // Element is a directory, they already exist locally, nothing to do
                continue
            } else {
                // Element is a file
                if fileIsPlaceholder(url: elementURL) {
                    // Element is an offloaded file, download it, do not wait for download to finish
                    if verbose {
                        print("  Downloading \(elementURL.path)")
                    }
                    TriggerDownloadFromCloud(placeholder: elementURL)
                } else {
                    // Elemint is a .DS_Store file
                    if elementURL.lastPathComponent == ".DS_Store" {
                        if verbose {
                            print("  Deleting    \(elementURL.path)")
                        }
                        DeleteItems(items: [elementURL])
                        continue
                    }
                    
                    // Element is an already downloaded file, nothing to do
                    continue
                }
            }
        }
    }
}
