import ArgumentParser
import Foundation


struct Fetch: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var output: Output = .file(URL(fileURLWithPath: "result.json"))

    @Option(name: .long)
    var order: Github.OrderBy = .descending

    @Option(name: .long)
    var sort: Github.SortBy = .updated

    @Option
    var page: Int?

    func runAsync() async throws {
        print("importing...")
        guard let token = Current.githubToken() else {
            throw AppError.missingGithubToken
        }

        var packageURLs = [String]()

        if let page = page {
            let results = try await Github.search(query: "in:path Package.swift",
                                                  token: token,
                                                  page: page,
                                                  perPage: 100)
            packageURLs = results.items.map(\.cloneUrl)
            print("received \(packageURLs.count) / \(results.totalCount)")
        } else {  // fetch all
            var currentPage = 1
            while true {
                defer { currentPage += 1 }
                print("fetching page \(currentPage)")
                do {
                    let results = try await Github.search(query: "in:path Package.swift",
                                                          sortBy: .updated,
                                                          orderBy: .descending,
                                                          token: token,
                                                          page: currentPage,
                                                          perPage: 100)
                    let items = results.items.map(\.cloneUrl)
                    packageURLs.append(contentsOf: items)
                    print("fetched \(packageURLs.count) / \(results.totalCount)")
                    if packageURLs.count >= results.totalCount {
                        break
                    }
                } catch Github.FetchError.noMoreResults {
                    break
                }
            }
        }

        switch output {
            case .file(let url):
                let data = try JSONEncoder().encode(packageURLs)
                print("saving to \(url.path)...")
                try data.write(to: url)
            case .stdout:
                for item in packageURLs {
                    print(item)
                }
        }
    }

}


extension Github.OrderBy: ExpressibleByArgument { }
extension Github.SortBy: ExpressibleByArgument { }
