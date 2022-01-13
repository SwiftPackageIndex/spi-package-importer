import ArgumentParser


@main
struct Main {
    static func main() async {
        await App.main()
    }
}


public struct App: ParsableCommand {
    public static var configuration = CommandConfiguration(
        abstract: "SPI Package Importer",
        subcommands: [Fetch.self, Merge.self]
    )

    public mutating func run() throws {}

    public init() {}
}
