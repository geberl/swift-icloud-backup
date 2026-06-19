import Foundation

// Human-readable byte count, e.g. "1.2 MB". Uses the file-system (base-10) unit
// scale and lets ByteCountFormatter pick the largest sensible unit.
func getSizeString(byteCount: Int64) -> String {
    // ByteCountFormatter renders 0 as "Zero KB"; prefer an explicit "0 bytes".
    if byteCount == 0 {
        return "0 bytes"
    }

    let byteCountFormatter = ByteCountFormatter()
    byteCountFormatter.allowedUnits = .useAll
    byteCountFormatter.countStyle = .file
    return byteCountFormatter.string(fromByteCount: byteCount)
}
