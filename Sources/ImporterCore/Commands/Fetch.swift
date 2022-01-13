import ArgumentParser
import Foundation


struct Fetch: AsyncParsableCommand {
    @Option(name: .shortAndLong)
    var output: Output = .stdout

    @Option(name: .long)
    var order: Github.OrderBy = .descending

    @Option(name: .long)
    var sort: Github.SortBy = .updated

    @Option(name: .shortAndLong)
    var page: Int?

    @Option(name: .long)
    var perPage: Int = 100

    func runAsync() async throws {
        print("importing...")
        guard let token = Current.githubToken() else {
            throw AppError.missingGithubToken
        }

        var packageURLs = [String]()
        let query = "in:path Package.swift archived:false fork:false"

        if let page = page {
            let results = try await Github.search(query: query,
                                                  sortBy: sort,
                                                  orderBy: order,
                                                  token: token,
                                                  page: page,
                                                  perPage: perPage)
            packageURLs = results.items.map(\.cloneUrl)
            print("received \(packageURLs.count) / \(results.totalCount)")
        } else {  // fetch all
            var currentPage = 1
            while true {
                defer { currentPage += 1 }
                print("fetching page \(currentPage)")
                do {
                    let results = try await Github.search(query: query,
                                                          sortBy: sort,
                                                          orderBy: order,
                                                          token: token,
                                                          page: currentPage,
                                                          perPage: perPage)
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

        try output.process(packageURLs: packageURLs)
    }

}


extension Github.OrderBy: ExpressibleByArgument { }
extension Github.SortBy: ExpressibleByArgument { }
