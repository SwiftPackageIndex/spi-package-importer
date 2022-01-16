import ArgumentParser


@main
public struct App: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "SPI Package Importer",
        subcommands: [Diff.self, Fetch.self, Merge.self]
    )

    public mutating func run() throws {}

    public init() {}
}
