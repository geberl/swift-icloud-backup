# swift-icloud-backup

*A macOS terminal app that copies your iCloud Documents onto a connected storage device, plus some helper tools*

![Swift](https://img.shields.io/badge/swift-5.5-orange.svg)
![Xcode](https://img.shields.io/badge/xcode-13.1-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Usage

### icloudbackup

*Copy files from your iCloud Documents directory to another destination.*

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

### icloudstats

*Show stats about your iCloud Documents directory*

```shell
# Show help
./icloudstats --help

# Show auto-detected documents directory
./icloudstats --show-src

# Scan and show stats
./icloudstats

# Scan and show stats of another directory
./icloudstats --src "/Users/guenther/Downloads/"
```

### iclouddownload

*Recursively download a directory below the iCloud Documents directory.*

```shell
# Show help
./iclouddownload --help

# Download everything below that base directory
./iclouddownload --base "/Users/guenther/Documents/books"

# Download everything below that base directory, showing individual files
./iclouddownload --base "/Users/guenther/Documents/books" --verbose
```

### icloudoffload

*Recursively remove the local copies of a directory below the iCloud Documents directory.*

```shell
# Show help
./icloudoffload --help

# Offload everything below that base directory
./icloudoffload --base "/Users/guenther/Documents/books"

# Offload everything below that base directory, showing individual files
./icloudoffload --base "/Users/guenther/Documents/books" --verbose
```

## Screenshots

TODO: These are old.

![screenshot1](/screenshots/1.png?raw=true "Screenshot 1")

![screenshot2](/screenshots/2.png?raw=true "Screenshot 2")

![screenshot3](/screenshots/3.png?raw=true "Screenshot 3")

![screenshot4](/screenshots/4.png?raw=true "Screenshot 4")

![screenshot5](/screenshots/5.png?raw=true "Screenshot 5")

## Dependencies

- [swift-argument-parser](https://github.com/apple/swift-argument-parser) (flags and options)
- [chalk](https://github.com/mxcl/Chalk) (colors)

## Why?

- Offloaded files only exist as a placeholder `*.plist` files on your drive
- These files only have a few bytes
- Because of this common filesystem usage tools like **DaisyDisk** are of no use to identify big files or get an overview about your actual storage usage
    - You need to analyze the content of the `*.plist` placeholder file along with real files
- Because of this common backup tools like `rsync` are of no use, would just copy the placeholder
    - You need to download, backup and offload the real file
- These tools help with those issues

## Know Issues

- Limitation: Using a non-APFS formatted drive as destination is not supported
    - Copying works fine, but afterwards the file attributes can't be set correctly for e.g. exFAT (probably because those attributes don't exist there?)
    - HFS+ might work, untested
- Limitation: Colorized output does not work in XCode's console
    - Colors are apparently not supported
    - Build and use in a real terminal
- Improvement: Progress indication is not yet shown during long running operations
    - Use [https://github.com/jkandzi/Progress.swift](https://github.com/jkandzi/Progress.swift)
    - Progress will not be shown correctly in XCode's console as well, cursor movements are apparently not supported, no problems in a real terminal
