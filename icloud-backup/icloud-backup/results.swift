//
//  results.swift
//  icloud-backup
//
//  Created by Günther Eberl on 2021-07-23.
//

import Foundation

func getSizeString(byteCount: Int64) -> String {
    let unit: String = "all"
    
    if byteCount == 0 {
        if unit == "all" {
            return "0 bytes"
        }
        return "0 " + unit
    }
    
    let byteCountFormatter = ByteCountFormatter()
    if unit == "bytes" {
        byteCountFormatter.allowedUnits = .useBytes
    } else if unit == "KB" {
        byteCountFormatter.allowedUnits = .useKB
    } else if unit == "MB" {
        byteCountFormatter.allowedUnits = .useMB
    } else if unit == "GB" {
        byteCountFormatter.allowedUnits = .useGB
    } else {
        byteCountFormatter.allowedUnits = .useAll
    }
    byteCountFormatter.countStyle = .file
    
    return byteCountFormatter.string(fromByteCount: byteCount)
}

func getPercentString(bytesDir: Int64, bytesTotal: Int64) -> String {
    let percent = ( Float(bytesDir) / Float(bytesTotal) ) * 100
    return String(format: "%2.1f", arguments: [percent])
}
