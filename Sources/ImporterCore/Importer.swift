import ArgumentParser
import Foundation


@main
struct App {
    static func main() async {
        await Importer.main()
    }
}


enum AppError: Error {
    case missingGithubToken
}


enum Output: ExpressibleByArgument {
    case file(URL)
    case stdout

    init?(argument: String) {
        switch argument {
            case "-":
                self = .stdout
            default:
                let url = URL(fileURLWithPath: argument)
                self = .file(url)
        }
    }
}


struct Importer: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var output: Output = .file(URL(fileURLWithPath: "result.json"))

    func runAsync() async throws {
        print("importing...")
        guard let token = Current.githubToken() else {
            throw AppError.missingGithubToken
        }
        let results = try await Github.search(query: "in:path Package.swift",
                                              token: token,
                                              page: 1,
                                              perPage: 100)
        let items = results.items.map(\.cloneUrl)
        print("received \(items.count) / \(results.totalCount)")
        switch output {
            case .file(let url):
                let data = try JSONEncoder().encode(items)
                print("saving to \(url.path)...")
                try data.write(to: url)
            case .stdout:
                for item in items {
                    print(item)
                }
        }
    }

}
