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

    static func merge(paths: [String]) throws -> Set<String> {
        var packageURLs = Set<String>()

        for path in paths {
            print("Merging \(path)")
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let packages = try JSONDecoder().decode([String].self, from: data)
            packageURLs.formUnion(packages)
        }
        print("Number of unique urls: \(packageURLs.count)")

        return packageURLs
    }
}
