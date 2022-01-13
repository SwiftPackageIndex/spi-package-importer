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

        switch output {
            case .file(let url):
                let data = try JSONEncoder().encode(packageURLs.sorted())
                print("saving to \(url.path)...")
                try data.write(to: url)
            case .stdout:
                for item in packageURLs.sorted() {
                    print(item)
                }
        }
    }


}
