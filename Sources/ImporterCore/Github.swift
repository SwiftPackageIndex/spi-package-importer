import Foundation


enum Github {
    struct SearchResults: Codable {
        var items: [Item]
        var totalCount: Int
        var incompleteResults: Bool

        struct Item: Codable {
            var cloneUrl: String

            enum CodingKeys: String, CodingKey {
                case cloneUrl = "clone_url"
            }
        }

        enum CodingKeys: String, CodingKey {
            case items
            case totalCount = "total_count"
            case incompleteResults = "incomplete_results"
        }
    }

    enum OrderBy: String {
        case ascending = "asc"
        case descending = "desc"

        var queryItem: URLQueryItem? { .init(name: "order", value: rawValue) }
    }

    enum SortBy: String {
        case bestMatch
        case forks
        case stars
        case updated

        var queryItem: URLQueryItem? {
            switch self {
                case .bestMatch:
                    return nil
                default:
                    return .init(name: "sort", value: rawValue)
            }
        }
    }

    enum FetchError: Error {
        case invalidResponse
        case invalidURL
        case noMoreResults
        case failed(String)

        var localizedDescription: String {
            switch self {
                case .invalidResponse:
                    return "invalid response"
                case .invalidURL:
                    return "invalid URL"
                case .noMoreResults:
                    return "no more results"
                case .failed(let string):
                    return "error: \(string)"
            }
        }
    }

    // Github repository search API
    // https://docs.github.com/en/rest/reference/search#search-repositories
    static func search(query: String, sortBy: SortBy = .bestMatch,  orderBy: OrderBy = .ascending, token: String, page: Int, perPage: Int = 100) async throws -> SearchResults {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = ["q": query,
                                 "page": "\(page)",
                                 "per_page": "\(perPage)"]
            .map { URLQueryItem.init(name: $0, value: $1) }
        + [sortBy.queryItem].compactMap { $0 }
        + [orderBy.queryItem].compactMap { $0 }
        guard let url = components.url else {
            throw FetchError.invalidURL
        }
        var req = URLRequest(url: url)
        req.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let resp = resp as? HTTPURLResponse else {
            throw FetchError.invalidResponse
        }
        switch resp.statusCode {
            case 200:
                break
            case 422:
                throw FetchError.noMoreResults
            default:
                throw FetchError.failed("unexpected status code: \(resp.statusCode)")
        }
        return try JSONDecoder().decode(SearchResults.self, from: data)
    }
}
