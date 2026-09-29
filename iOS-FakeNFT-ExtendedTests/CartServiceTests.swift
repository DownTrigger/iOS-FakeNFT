import XCTest
@testable import iOS_FakeNFT_Extended

final class CartServiceTests: XCTestCase {

    func testLoadCartKeepsOrderOfNftsFromOrder() async throws {
        // Given
        let client = NetworkClientStub(orderIds: ["3", "1", "2"])
        let service = CartServiceImpl(networkClient: client)

        // When
        let items = try await service.loadCart()

        // Then
        XCTAssertEqual(items.map(\.id), ["3", "1", "2"])
    }

    func testLoadCartWithEmptyOrderReturnsEmptyList() async throws {
        // Given
        let client = NetworkClientStub(orderIds: [])
        let service = CartServiceImpl(networkClient: client)

        // When
        let items = try await service.loadCart()

        // Then
        XCTAssertTrue(items.isEmpty)
    }

    func testLoadCartThrowsWhenNftRequestFails() async {
        // Given
        let client = NetworkClientStub(orderIds: ["1", "2"], failingNftId: "2")
        let service = CartServiceImpl(networkClient: client)

        // When / Then
        do {
            _ = try await service.loadCart()
            XCTFail("Expected error")
        } catch {
            XCTAssertTrue(error is NetworkClientError)
        }
    }
}

private struct NetworkClientStub: NetworkClient {
    let orderIds: [String]
    var failingNftId: String?

    func send(request: NetworkRequest) async throws -> Data {
        if request is OrderRequest {
            return try JSONSerialization.data(withJSONObject: ["id": "1", "nfts": orderIds])
        }
        guard let nftRequest = request as? NFTRequest, nftRequest.id != failingNftId else {
            throw NetworkClientError.httpStatusCode(404)
        }
        let nft: [String: Any] = [
            "id": nftRequest.id,
            "name": "NFT \(nftRequest.id)",
            "images": [],
            "rating": 3,
            "price": 1.0
        ]
        return try JSONSerialization.data(withJSONObject: nft)
    }

    func send<T: Decodable>(request: NetworkRequest) async throws -> T {
        try JSONDecoder().decode(T.self, from: try await send(request: request))
    }
}
