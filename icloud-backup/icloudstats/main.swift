import Foundation
import ArgumentParser

struct IcloudstatsOptions: ParsableArguments {
    @Flag(name: .long, help: "Print version and exit.") var version = false
    @Flag(name: .long, help: "Show auto-detected source path and exit.") var showSrc = false
    @Option(help: ArgumentHelp("Override the source path.", valueName: "path")) var src = ""
    // --help is automatically included
}

let cli = CLI(options: IcloudstatsOptions.parseOrExit(), version: "1.5.0")

do {
    try cli.run()
} catch ArgumentError.SourceDoesNotExist {
    fputs("Source path does not exist", stderr)
    exit(1)
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
