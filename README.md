# swift-icloud-backup

*A macOS terminal app that copies your iCloud Documents onto a connected storage device*

![Swift](https://img.shields.io/badge/swift-5.3-brightgreen.svg)
![Xcode](https://img.shields.io/badge/xcode-12.5-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey.svg)

## Usage

```shell
# Analyze source and destination and print what would happen
./icloud-backup --dry-run --dst "/Volumes/T7 Black/cloud-backups/iCloud_Drive/"

# Show auto-detected documents directory
./icloud-backup --show-src

# Perform backup
./icloud-backup --dst "/Volumes/T7 Black/cloud-backups/iCloud_Drive/"

# Backup another directory
./icloud-backup --src "/Users/guenther/Downloads/" --dst "/Volumes/T7 Black/cloud-backups/Downloads/"

# Show help
./icloud-backup --help
```

## Screenshots

TODO

## Dependencies

- [https://github.com/apple/swift-argument-parser](https://github.com/apple/swift-argument-parser)

## Why?

- Offloaded files only exist as a placeholder `*.plist` files on your drive
- These files only have a few bytes
- Because of this common backup tools like `rsync` are of no use to download and backup the real file, not just the placeholder
