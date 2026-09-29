import XCTest
@testable import iOS_FakeNFT_Extended

final class CartServiceTests: XCTestCase {

    func testLoadCartKeepsOrderOfNftsFromOrder() async throws {
        // Given
        let service = makeService(orderIds: ["3", "1", "2"])

        // When
        let items = try await service.loadCart()

        // Then
        XCTAssertEqual(items.map(\.id), ["3", "1", "2"])
    }

    func testLoadCartWithEmptyOrderReturnsEmptyList() async throws {
        // Given
        let service = makeService(orderIds: [])

        // When
        let items = try await service.loadCart()

        // Then
        XCTAssertTrue(items.isEmpty)
    }

    func testLoadCartThrowsWhenNftRequestFails() async {
        // Given
        let service = makeService(orderIds: ["1", "2"], failingNftId: "2")

        // When / Then
        do {
            _ = try await service.loadCart()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkClientError)
        }
    }

    func testOrderUpdateRequestBodyContainsAllIds() throws {
        // Given
        let request = OrderUpdateRequest(nftIds: ["a", "b"])

        // Then
        XCTAssertEqual(request.httpMethod, .put)
        XCTAssertEqual(String(bytes: try XCTUnwrap(request.rawBody), encoding: .utf8), "nfts=a&nfts=b")
    }

    func testOrderUpdateRequestBodyIsEmptyForEmptyCart() throws {
        // Given
        let request = OrderUpdateRequest(nftIds: [])

        // Then
        XCTAssertEqual(try XCTUnwrap(request.rawBody), Data())
    }

    private func makeService(orderIds: [String], failingNftId: String? = nil) -> CartServiceImpl {
        CartServiceImpl(
            networkClient: OrderNetworkClientStub(orderIds: orderIds),
            nftService: NftServiceStub(failingNftId: failingNftId),
            orderUpdater: OrderUpdaterStub()
        )
    }
}

private struct OrderNetworkClientStub: NetworkClient {
    let orderIds: [String]

    func send(request: NetworkRequest) async throws -> Data {
        guard request is OrderRequest else {
            throw NetworkClientError.incorrectRequest("Unexpected request")
        }
        return try JSONSerialization.data(withJSONObject: ["id": "1", "nfts": orderIds])
    }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        try JSONDecoder().decode(T.self, from: try await send(request: request))
    }
}

private struct NftServiceStub: NftService {
    let failingNftId: String?

    func loadNft(id: String) async throws -> Nft {
        if id == failingNftId {
            throw NetworkClientError.httpStatusCode(404)
        }
        return .stub(id: id)
    }
}

private struct OrderUpdaterStub: CartOrderUpdater {
    func updateOrder(nftIds: [String]) async throws {}
}
