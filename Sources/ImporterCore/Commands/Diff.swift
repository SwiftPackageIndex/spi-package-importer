import ArgumentParser
import Foundation


struct Diff: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var output: Output = .stdout

    @Argument(help: "A list of package URLs in JSON format to diff against the index package list.")
    var files: [String]

    static let indexListURL = URL(string: "https://raw.githubusercontent.com/SwiftPackageIndex/PackageList/main/packages.json")!

    static func indexList() throws -> [String] {
        let data = try Data(contentsOf: indexListURL)
        return try JSONDecoder().decode([String].self, from: data)
    }

    func runAsync() async throws {
        let packageURLs = Set(try Merge.merge(paths: files).map(Item.init(url:)))
        let notInIndex = try packageURLs.subtracting(Self.indexList().map(Item.init(url:)))

        try output.process(packageURLs: notInIndex.map(\.url).sorted())
    }

    struct Item: Equatable, Hashable {
        var url: String
        var canonicalURL: String

        init(url: String) {
            self.url = url
            self.canonicalURL = url.lowercased()
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.canonicalURL == rhs.canonicalURL
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(canonicalURL)
        }
    }
}
