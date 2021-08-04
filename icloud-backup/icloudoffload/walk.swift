import Foundation

func OffloadItems(baseURL: URL, verbose: Bool) {
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
                // Element is a directory, they always exist locally, can't be offloaded, nothing to do
                continue
            } else {
                // Element is a file
                if fileIsPlaceholder(url: elementURL) {
                    // Element is an offloaded file, nothing to do
                    continue
                } else {
                    // Elemint is a .DS_Store file
                    if elementURL.lastPathComponent == ".DS_Store" {
                        if verbose {
                            print("  Deleting    \(elementURL.path)")
                        }
                        DeleteItems(items: [elementURL])
                        continue
                    }
                    
                    // Element is a downloaded file, offload it
                    if verbose {
                        print("  Offloading  \(elementURL.path)")
                    }
                    TriggerOffloadToCloud(file: elementURL)
                }
            }
        }
    }
}
