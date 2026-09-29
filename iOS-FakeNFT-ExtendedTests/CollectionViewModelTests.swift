import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class CollectionViewModelTests: XCTestCase {

    func testLoadNftsKeepsCollectionOrder() async {
        // Given
        let service = NftServiceStub(delays: ["1": 30, "2": 20, "3": 10])
        let viewModel = CollectionViewModel(collection: .stub(nfts: ["1", "2", "3"]), nftService: service)

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.cells.map(\.id), ["1", "2", "3"])
        XCTAssertNil(viewModel.alert)
    }

    func testLoadNftsFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let service = NftServiceStub(error: NetworkClientError.urlSessionError)
        let viewModel = CollectionViewModel(collection: .stub(nfts: ["1"]), nftService: service)

        // When
        await viewModel.loadNfts()

        // Then
        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.cells.isEmpty)
    }

    func testLoadNftsCancellationDoesNotShowAlert() async {
        // Given
        let service = NftServiceStub(error: CancellationError())
        let viewModel = CollectionViewModel(collection: .stub(nfts: ["1"]), nftService: service)

        // When
        await viewModel.loadNfts()

        // Then
        guard case .idle = viewModel.state else {
            return XCTFail("Expected idle state")
        }
        XCTAssertNil(viewModel.alert)
    }

    func testLoadNftsDoesNotReloadLoadedNfts() async {
        // Given
        let service = NftServiceStub()
        let viewModel = CollectionViewModel(collection: .stub(nfts: ["1", "2"]), nftService: service)

        // When
        await viewModel.loadNfts()
        await viewModel.loadNfts()

        // Then
        let requestCount = await service.requestCount
        XCTAssertEqual(requestCount, 2)
    }

    func testCellsMapNftFields() async {
        // Given
        let service = NftServiceStub()
        let viewModel = CollectionViewModel(collection: .stub(nfts: ["1"]), nftService: service)

        // When
        await viewModel.loadNfts()

        // Then
        let cell = viewModel.cells.first
        XCTAssertEqual(cell?.name, "NFT 1")
        XCTAssertEqual(cell?.rating, 3)
        XCTAssertEqual(cell?.priceText, PriceFormatter.string(from: 1.5))
        XCTAssertEqual(cell?.imageURL, URL(string: "https://example.com/1.png"))
        XCTAssertEqual(cell?.isLiked, false)
        XCTAssertEqual(cell?.isInCart, false)
    }
}

private actor NftServiceStub: NftService {
    private let delays: [String: Int]
    private let error: Error?
    private(set) var requestCount = 0

    init(delays: [String: Int] = [:], error: Error? = nil) {
        self.delays = delays
        self.error = error
    }

    func loadNft(id: String) async throws -> Nft {
        requestCount += 1
        if let error {
            throw error
        }
        if let delay = delays[id] {
            try await Task.sleep(for: .milliseconds(delay))
        }
        return Nft(
            id: id,
            name: "NFT \(id)",
            images: [URL(string: "https://example.com/\(id).png")].compactMap { $0 },
            rating: 3,
            price: 1.5,
            author: "John Doe"
        )
    }
}

private extension NftCollection {
    static func stub(nfts: [String]) -> NftCollection {
        NftCollection(
            id: "1",
            name: "Peach",
            cover: nil,
            nfts: nfts,
            description: "",
            author: "John Doe",
            website: "https://example.com"
        )
    }
}
