import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class CartViewModelTests: XCTestCase {

    func testLoadSuccessSetsLoadedStateAndTotalPrice() async {
        // Given
        let service = CartServiceStub(result: .success([
            .stub(id: "1", price: 1.5),
            .stub(id: "2", price: 2.25)
        ]))
        let viewModel = CartViewModel()

        // When
        await viewModel.load(using: service)

        // Then
        XCTAssertEqual(viewModel.items.map(\.id), ["1", "2"])
        XCTAssertEqual(viewModel.totalPrice, 3.75, accuracy: 0.001)
        XCTAssertNil(viewModel.alert)
    }

    func testLoadEmptyCart() async {
        // Given
        let service = CartServiceStub(result: .success([]))
        let viewModel = CartViewModel()

        // When
        await viewModel.load(using: service)

        // Then
        XCTAssertTrue(viewModel.items.isEmpty)
        XCTAssertEqual(viewModel.totalPrice, 0)
    }

    func testLoadFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let service = CartServiceStub(result: .failure(NetworkClientError.urlSessionError))
        let viewModel = CartViewModel()

        // When
        await viewModel.load(using: service)

        // Then
        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.items.isEmpty)
    }

    func testLoadCancellationDoesNotShowAlert() async {
        // Given
        let service = CartServiceStub(result: .failure(URLError(.cancelled)))
        let viewModel = CartViewModel()

        // When
        await viewModel.load(using: service)

        // Then
        guard case .idle = viewModel.state else {
            return XCTFail("Expected idle state")
        }
        XCTAssertNil(viewModel.alert)
    }
}

private struct CartServiceStub: CartService {
    let result: Result<[Nft], Error>

    func loadCart() async throws -> [Nft] {
        try result.get()
    }
}

extension Nft {
    static func stub(id: String, price: Double = 1) -> Nft {
        Nft(id: id, name: "NFT \(id)", images: [], rating: 3, price: price, author: "1")
    }
}
