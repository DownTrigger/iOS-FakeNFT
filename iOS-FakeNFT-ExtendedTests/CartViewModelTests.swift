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

extension CartViewModelTests {

    func testSortByTitleIsDefault() async {
        // Given
        let viewModel = await loadedViewModel()

        // Then
        XCTAssertEqual(viewModel.sortOption, .byTitle)
        XCTAssertEqual(viewModel.items.map(\.name), ["April", "Greena", "Spring"])
    }

    func testSortByPriceDescending() async {
        // Given
        let viewModel = await loadedViewModel()

        // When
        viewModel.applySort(.byPrice)

        // Then
        XCTAssertEqual(viewModel.items.map(\.name), ["Greena", "Spring", "April"])
    }

    func testSortByRatingDescending() async {
        // Given
        let viewModel = await loadedViewModel()

        // When
        viewModel.applySort(.byRating)

        // Then
        XCTAssertEqual(viewModel.items.map(\.name), ["Spring", "April", "Greena"])
    }

    private func loadedViewModel() async -> CartViewModel {
        let service = CartServiceStub(result: .success([
            Nft(id: "1", name: "Spring", images: [], description: "", rating: 5, price: 2, author: "1"),
            Nft(id: "2", name: "April", images: [], description: "", rating: 3, price: 1, author: "1"),
            Nft(id: "3", name: "Greena", images: [], description: "", rating: 1, price: 3, author: "1")
        ]))
        let viewModel = CartViewModel()
        await viewModel.load(using: service)
        return viewModel
    }
}

extension CartViewModelTests {

    func testConfirmDeleteRemovesNftAndSendsRemainingIds() async {
        // Given
        let service = CartServiceStub(result: .success([.stub(id: "1", price: 1), .stub(id: "2", price: 2)]))
        let viewModel = CartViewModel()
        await viewModel.load(using: service)
        viewModel.requestDelete(.stub(id: "1", price: 1))

        // When
        await viewModel.confirmDelete(using: service)

        // Then
        let sentOrders = await service.sentOrders
        XCTAssertEqual(sentOrders, [["2"]])
        XCTAssertEqual(viewModel.items.map(\.id), ["2"])
        XCTAssertEqual(viewModel.totalPrice, 2, accuracy: 0.001)
        XCTAssertNil(viewModel.nftToDelete)
    }

    func testConfirmDeleteLastNftMakesCartEmpty() async {
        // Given
        let service = CartServiceStub(result: .success([.stub(id: "1")]))
        let viewModel = CartViewModel()
        await viewModel.load(using: service)
        viewModel.requestDelete(.stub(id: "1"))

        // When
        await viewModel.confirmDelete(using: service)

        // Then
        let sentOrders = await service.sentOrders
        XCTAssertEqual(sentOrders, [[]])
        XCTAssertTrue(viewModel.items.isEmpty)
    }

    func testConfirmDeleteFailureKeepsItemsAndShowsAlert() async {
        // Given
        let service = CartServiceStub(
            result: .success([.stub(id: "1"), .stub(id: "2")]),
            updateError: NetworkClientError.httpStatusCode(500)
        )
        let viewModel = CartViewModel()
        await viewModel.load(using: service)
        viewModel.requestDelete(.stub(id: "1"))

        // When
        await viewModel.confirmDelete(using: service)

        // Then
        XCTAssertEqual(viewModel.items.map(\.id), ["1", "2"])
        XCTAssertNotNil(viewModel.alert)
        XCTAssertNil(viewModel.nftToDelete)
        XCTAssertFalse(viewModel.isDeleting)
    }

    func testCancelDeleteClearsSelection() {
        // Given
        let viewModel = CartViewModel()
        viewModel.requestDelete(.stub(id: "1"))

        // When
        viewModel.cancelDelete()

        // Then
        XCTAssertNil(viewModel.nftToDelete)
    }
}

extension CartViewModelTests {

    func testRefreshUpdatesItems() async {
        // Given
        let viewModel = CartViewModel()
        await viewModel.load(using: CartServiceStub(result: .success([.stub(id: "1")])))

        // When
        await viewModel.refresh(using: CartServiceStub(result: .success([.stub(id: "1"), .stub(id: "2")])))

        // Then
        XCTAssertEqual(viewModel.items.map(\.id), ["1", "2"])
    }

    func testRefreshFailureKeepsItemsAndShowsAlert() async {
        // Given
        let viewModel = CartViewModel()
        await viewModel.load(using: CartServiceStub(result: .success([.stub(id: "1")])))

        // When
        await viewModel.refresh(using: CartServiceStub(result: .failure(NetworkClientError.urlSessionError)))

        // Then
        XCTAssertEqual(viewModel.items.map(\.id), ["1"])
        XCTAssertNotNil(viewModel.alert)
    }

    func testRequestDeleteIsIgnoredWhileAnotherIsSelected() {
        // Given
        let viewModel = CartViewModel()
        viewModel.requestDelete(.stub(id: "1"))

        // When
        viewModel.requestDelete(.stub(id: "2"))

        // Then
        XCTAssertEqual(viewModel.nftToDelete?.id, "1")
    }
}

private actor CartServiceStub: CartService {
    let result: Result<[Nft], Error>
    let updateError: Error?
    private(set) var sentOrders: [[String]] = []

    init(result: Result<[Nft], Error>, updateError: Error? = nil) {
        self.result = result
        self.updateError = updateError
    }

    func loadCart() async throws -> [Nft] {
        try result.get()
    }

    func updateOrder(nftIds: [String]) async throws {
        sentOrders.append(nftIds)
        if let updateError {
            throw updateError
        }
    }
}

extension Nft {
    static func stub(id: String, price: Double = 1) -> Nft {
        Nft(id: id, name: "NFT \(id)", images: [], description: "", rating: 3, price: price, author: "1")
    }
}
