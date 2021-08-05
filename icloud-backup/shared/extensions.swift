import Foundation

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func lPad(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else { return self }
    }
    
    func rPad(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return self + String(repeatElement(character, count: toLength - stringLength))
        } else { return self }
    }
}

extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
}

extension FileManager {
    func dirExists(atPath: String) -> Bool {
        var isDir: ObjCBool = ObjCBool(true)
        return fileExists(atPath: atPath, isDirectory: &isDir)
    }
    
    func isDirectory(url: URL) -> Bool? {
        var isDir: ObjCBool = ObjCBool(false)
        if fileExists(atPath: url.path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            return nil
        }
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
