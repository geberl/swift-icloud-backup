import Foundation
import ArgumentParser

struct IclouddownloadOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.") var version = false
    @Flag(name: .long, help: "Show the paths of all downloaded files.") var verbose = false
    @Option(help: ArgumentHelp("Set the base path.", valueName: "path")) var base = ""
    // --help is automatically included
}

let cli = CLI(options: IclouddownloadOptions.parseOrExit(), version: "1.5.0")

do {
    try cli.run()
} catch ArgumentError.BaseUnset {
    fputs("Base path must be set (--base <path>)", stderr)
    exit(1)
} catch ArgumentError.BaseDoesNotExist {
    fputs("Base path does not exist", stderr)
    exit(1)
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
