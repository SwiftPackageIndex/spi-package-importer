import ArgumentParser
import Foundation


@main
struct App {
    static func main() async {
        await Importer.main()
    }
}


struct Importer: AsyncParsableCommand {

    func runAsync() async throws {
        print("importing...")
        let token = try Keychain.readString(
            service: "Github finestructure Personal Access Token",
            account: "finestructure"
        )
        let query = "in:path Package.swift"
        let results = try await Github.search(query: query,
                                              token: token,
                                              page: 1, perPage: 100)
        print("received \(results.items.count) / \(results.totalCount)")
        let data = try JSONEncoder().encode(results.items)
        let saveUrl = URL(fileURLWithPath: "/Users/sas/Downloads/results.json")
        print("saving...")
        try data.write(to: saveUrl)
    }

}
