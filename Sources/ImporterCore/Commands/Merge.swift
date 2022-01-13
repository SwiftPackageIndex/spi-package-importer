import ArgumentParser
import Foundation


struct Merge: AsyncParsableCommand {
    @Argument(help: "A list of package URLs in JSON format to merge.")
    var files: [String] = []

    @Option(name: .shortAndLong)
    var output: Output = .stdout

    func runAsync() async throws {
        var packageURLs = Set<String>()

        for fname in files {
            print("Merging \(fname)")
            let url = URL(fileURLWithPath: fname)
            let data = try Data(contentsOf: url)
            let packages = try JSONDecoder().decode([String].self, from: data)
            packageURLs.formUnion(packages)
        }

        print("Number of unique urls: \(packageURLs.count)")

        try output.process(packageURLs: packageURLs.sorted())
    }


}
