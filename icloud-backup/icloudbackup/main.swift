import Foundation
import ArgumentParser

struct IcloudbackupOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.") var version = false
    @Flag(name: .long, help: "Show auto-detected source path and exit.") var showSrc = false
    @Flag(name: .long, help: "Analyze source and destination trees and print what would happen.") var dryRun = false
    @Flag(name: .long, help: "Show the paths of all individual items after analyzing source and destination.") var verbose = false
    @Option(help: ArgumentHelp("Override the source path.", valueName: "path")) var src = ""
    @Option(help: ArgumentHelp("Set the destination path.", valueName: "path")) var dst = ""
    // --help is automatically included
}

let cli = CLI(options: IcloudbackupOptions.parseOrExit(), version: "1.4.0")

do {
    try cli.run()
} catch ArgumentError.DestinationUnset {
    fputs("Destination path must be set (--dst <path>)", stderr)
    exit(1)
} catch ArgumentError.DestinationDoesNotExist {
    fputs("Destination path does not exist", stderr)
    exit(1)
} catch ArgumentError.SourceDoesNotExist {
    fputs("Source path does not exist", stderr)
    exit(1)
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
