import ArgumentParser
import Foundation


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

    func process(packageURLs: [String]) throws {
        switch self {
            case .file(let url):
                let data = try JSONEncoder().encode(packageURLs)
                print("saving to \(url.path)...")
                try data.write(to: url)
            case .stdout:
                for url in packageURLs {
                    print(url)
                }
        }
    }
}
