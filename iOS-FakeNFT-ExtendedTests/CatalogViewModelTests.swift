import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class CatalogViewModelTests: XCTestCase {

    private func makeCollections(count: Int) -> [NftCollection] {
        (0..<count).map { index in
            NftCollection(
                id: String(index),
                name: "Collection \(index)",
                cover: nil,
                nfts: (0..<(index % 4 + 1)).map { String($0) },
                description: "",
                author: "",
                website: ""
            )
        }
    }

    func testApplySortByNftCountLoadsAllPagesAndSortsDescending() async {
        // Given
        let service = CollectionsServiceStub(collections: makeCollections(count: 7))
        let viewModel = CatalogViewModel(service: service)

        // When
        await viewModel.applySort(.byNftCount)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests.map(\.page), [0, 1])
        XCTAssertTrue(requests.allSatisfy { $0.sortBy == nil })
        XCTAssertEqual(viewModel.collections.count, 7)
        XCTAssertEqual(viewModel.collections.map(\.nftCount), viewModel.collections.map(\.nftCount).sorted(by: >))
        XCTAssertFalse(viewModel.isInitialLoading)
    }

    func testApplySortByTitleLoadsFirstPageOnly() async {
        // Given
        let service = CollectionsServiceStub(collections: makeCollections(count: 7))
        let viewModel = CatalogViewModel(service: service)

        // When
        await viewModel.applySort(.byTitle)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests.map(\.page), [0])
        XCTAssertEqual(requests.map(\.sortBy), ["name,asc"])
        XCTAssertEqual(viewModel.collections.count, 5)
    }

    func testSwitchingFromTitleToNftCountLoadsRemainingPages() async {
        // Given
        let service = CollectionsServiceStub(collections: makeCollections(count: 7))
        let viewModel = CatalogViewModel(service: service)
        await viewModel.applySort(.byTitle)

        // When
        await viewModel.applySort(.byNftCount)

        // Then
        XCTAssertEqual(viewModel.collections.count, 7)
        XCTAssertEqual(viewModel.collections.map(\.nftCount), viewModel.collections.map(\.nftCount).sorted(by: >))
    }

    func testFirstPageFailureSetsLoadErrorAndShowsAlert() async {
        // Given
        let service = CollectionsServiceStub(collections: makeCollections(count: 7), error: NetworkClientError.urlSessionError)
        let viewModel = CatalogViewModel(service: service)

        // When
        await viewModel.applySort(.byNftCount)

        // Then
        XCTAssertTrue(viewModel.hasLoadError)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.isInitialLoading)
    }

    func testRefreshByNftCountReloadsAllPages() async {
        // Given
        let service = CollectionsServiceStub(collections: makeCollections(count: 7))
        let viewModel = CatalogViewModel(service: service)
        await viewModel.applySort(.byNftCount)

        // When
        await viewModel.refresh()

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests.count, 4)
        XCTAssertEqual(viewModel.collections.count, 7)
    }
}

private actor CollectionsServiceStub: CollectionsService {
    struct Request: Equatable {
        let page: Int
        let sortBy: String?
    }

    private let collections: [NftCollection]
    private let error: Error?
    private(set) var requests: [Request] = []

    init(collections: [NftCollection], error: Error? = nil) {
        self.collections = collections
        self.error = error
    }

    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection] {
        requests.append(Request(page: page, sortBy: sortBy))
        if let error { throw error }
        let start = page * size
        guard start < collections.count else { return [] }
        return Array(collections[start..<min(start + size, collections.count)])
    }

    func loadCollection(id: String) async throws -> NftCollection {
        if let error { throw error }
        guard let collection = collections.first(where: { $0.id == id }) else {
            throw NetworkClientError.urlSessionError
        }
        return collection
    }
}
