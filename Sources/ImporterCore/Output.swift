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
}
