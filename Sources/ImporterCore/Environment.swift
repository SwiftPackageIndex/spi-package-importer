import Foundation


#if DEBUG
var Current: Environment = .live
#else
let Current: Environment = .live
#endif


struct Environment {
    var githubToken: () -> String?
}


extension Environment {
    static let live = Self.init(
        githubToken: {
            if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] {
                return token
            } else {
                return try? Keychain.readString(
                    service: "Github Personal Access Token - spi-importer",
                    account: "spi-importer"
                )
            }
        }
    )
}
