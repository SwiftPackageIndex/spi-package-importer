import XCTest
import class Foundation.Bundle

@testable import ImporterCore


final class ImporterCoreTests: XCTestCase {

    func test_Diff_Item_Equatable() throws {
        XCTAssert(Diff.Item(url: "a") == Diff.Item(url: "A"))
        XCTAssert(Diff.Item(url: "a") != Diff.Item(url: "b"))
    }

    func test_Diff_Item_Hashable() throws {
        var urls = Set<Diff.Item>()
        urls.insert(.init(url: "a"))
        XCTAssertEqual(urls.count, 1)
        urls.insert(.init(url: "A"))
        XCTAssertEqual(urls.count, 1)
        urls.insert(.init(url: "B"))
        XCTAssertEqual(urls.count, 2)
        XCTAssertEqual(urls.map(\.url).sorted(), ["B", "a"])


        XCTAssertEqual(urls.subtracting(Set([.init(url: "A")])).map(\.url), ["B"])
    }

}
