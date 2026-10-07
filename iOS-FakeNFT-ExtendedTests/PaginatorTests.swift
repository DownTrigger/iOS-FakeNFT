import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class PaginatorTests: XCTestCase {
    private struct Item: Identifiable {
        let id: Int
    }

    func testIncompletePageInTheMiddleDoesNotStopPagination() async throws {
        // Given
        let pageSizes = [4, 5, 0]
        var nextId = 0
        let paginator = Paginator<Item>(pageSize: 5) { page, _ in
            let count = pageSizes[page]
            defer { nextId += count }
            return (nextId..<(nextId + count)).map { Item(id: $0) }
        }

        // When
        try await paginator.loadAllPages()

        // Then
        XCTAssertEqual(paginator.items.count, 9)
        XCTAssertFalse(paginator.hasMorePages)
    }

    func testItemRepeatedOnNextPageIsAddedOnce() async throws {
        // Given
        let pages = [[0, 1, 2], [2, 3, 4], []]
        let paginator = Paginator<Item>(pageSize: 3) { page, _ in
            pages[page].map { Item(id: $0) }
        }

        // When
        try await paginator.loadAllPages()

        // Then
        XCTAssertEqual(paginator.items.map(\.id), [0, 1, 2, 3, 4])
    }
}
