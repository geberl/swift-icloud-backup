# swift-icloud-backup

*A macOS terminal app that copies your iCloud Documents onto a connected storage device*

![Swift](https://img.shields.io/badge/swift-5.4-orange.svg)
![Xcode](https://img.shields.io/badge/xcode-12.5.1-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Usage

```shell
# Show help
./icloudbackup --help

# Show auto-detected documents directory
./icloudbackup --show-src

# Analyze source and destination trees and print what would happen
./icloudbackup --dry-run --dst "/Volumes/Black/icloud-documents-backup/"

# Analyze source and destination trees and print what would happen with all individual files
./icloudbackup --dry-run --dst "/Volumes/Black/icloud-documents-backup/" --verbose

# Perform backup
./icloudbackup --dst "/Volumes/Black/icloud-documents-backup/"

# Backup another directory
./icloudbackup --src "/Users/guenther/Downloads/" --dst "/Volumes/Black/icloud-documents-backup/"
```

## Screenshots

![screenshot1](/screenshots/1.png?raw=true "Screenshot 1")

![screenshot2](/screenshots/2.png?raw=true "Screenshot 2")

![screenshot3](/screenshots/3.png?raw=true "Screenshot 3")

## Dependencies

- [https://github.com/apple/swift-argument-parser](https://github.com/apple/swift-argument-parser)

## Why?

- Offloaded files only exist as a placeholder `*.plist` files on your drive
- These files only have a few bytes
- Because of this common backup tools like `rsync` are of no use, would just copy the placeholder
- You need to download, backup and offload the real file
- This tool does exactly that

## Know Issues

- Limitation: Using a non-APFS formatted drive as destination is not supported
    - Copying works fine, but afterwards the file attributes can't be set correctly for e.g. exFAT (probably because those attributes don't exist there?)
    - HFS+ might work, untested
- Improvement: Progress indication is not yet shown during long running operations
    - Maybe use [https://github.com/jkandzi/Progress.swift](https://github.com/jkandzi/Progress.swift)
