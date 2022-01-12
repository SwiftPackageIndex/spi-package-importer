import ArgumentParser
import Foundation


//@main
public struct Importer: ParsableCommand {

    public init() {}

    public mutating func run() throws {

        Task {
            do {
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
                _exit(0)
            } catch {
                _exit(error: error)
            }
        }

        RunLoop.main.run()
    }

}


func _exit(error: Error) -> Never {
    let msg = (error as? Github.FetchError)?.localizedDescription ?? error.localizedDescription
    print(msg)
    fflush(stdout)
    fflush(stderr)
    _exit(1)
}


extension Task where Success == Void, Failure == Error {

    static func `await`(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) throws {
        let group = DispatchGroup()
        group.enter()

        Task.detached {
            defer { group.leave() }
            try await operation()
        }

        group.wait()
    }

}
