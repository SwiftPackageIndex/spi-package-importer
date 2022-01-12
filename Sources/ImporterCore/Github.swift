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

    enum FetchError: Error {
        case invalidResponse
        case invalidURL
        case failed(String)

        var localizedDescription: String {
            switch self {
                case .invalidResponse:
                    return "invalid response"
                case .invalidURL:
                    return "invalid URL"
                case .failed(let string):
                    return "error: \(string)"
            }
        }
    }

    static func search(query: String, token: String, page: Int, perPage: Int = 100) async throws -> SearchResults {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = ["q": query,
                                 "page": "\(page)",
                                 "per_page": "\(perPage)"]
            .map { URLQueryItem.init(name: $0, value: $1) }
        guard let url = components.url else {
            throw FetchError.invalidURL
        }
        var req = URLRequest(url: url)
        req.addValue("Token \(token)", forHTTPHeaderField: "Authorization")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let resp = resp as? HTTPURLResponse else {
            throw FetchError.invalidResponse
        }
        guard resp.statusCode == 200 else {
            throw FetchError.failed("unexpected status code: \(resp.statusCode)")
        }
        return try JSONDecoder().decode(SearchResults.self, from: data)
    }
}
