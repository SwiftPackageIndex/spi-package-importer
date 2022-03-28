import ArgumentParser
import Foundation


struct Merge: AsyncParsableCommand {
    @Argument(help: "A list of package URLs in JSON format to merge.")
    var files: [String] = []

    @Option(name: .shortAndLong)
    var output: Output = .stdout

    func runAsync() async throws {
        let packageURLs = try Self.merge(paths: files)

        try output.process(packageURLs: packageURLs.sorted())
    }

    static func merge(paths: [String]) throws -> [String] {
        for path in paths {
            print("Merging \(path)")
        }

        let packageLists = try paths
            .map(URL.init(fileURLWithPath:))
            .map { try Data.init(contentsOf: $0) }
            .map { try JSONDecoder().decode([String].self, from: $0) }

        let result = merge(packageLists)

        print("Number of unique urls: \(result.count)")

        return result
    }

    static func merge(_ packageLists: [String]...) -> [String] {
        merge(packageLists)
    }

    static func merge(_ packageLists: [[String]]) -> [String] {
        var packageURLs = Set<String>()
        for p in packageLists {
            packageURLs.formUnion(p)
        }
        return packageURLs.sorted()
    }

}
