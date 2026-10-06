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

    func testRemoveSendsRemoveChange() async throws {
        // Given
        let orderService = UserOrderServiceStub(orderIds: ["1", "2"])
        let service = CartServiceImpl(orderService: orderService, nftService: NftServiceStub(failingNftId: nil))

        // When
        try await service.remove(nftId: "1")

        // Then
        let changes = await orderService.changes
        XCTAssertEqual(changes, [.remove("1")])
    }

    func testClearClearsOrder() async throws {
        // Given
        let orderService = UserOrderServiceStub(orderIds: ["1"])
        let service = CartServiceImpl(orderService: orderService, nftService: NftServiceStub(failingNftId: nil))

        // When
        try await service.clear()

        // Then
        let clearCount = await orderService.clearCount
        XCTAssertEqual(clearCount, 1)
    }

    private func makeService(orderIds: [String], failingNftId: String? = nil) -> CartServiceImpl {
        CartServiceImpl(
            orderService: UserOrderServiceStub(orderIds: orderIds),
            nftService: NftServiceStub(failingNftId: failingNftId)
        )
    }
}

private actor UserOrderServiceStub: UserOrderService {
    let orderIds: [String]
    private(set) var changes: [IdChange] = []
    private(set) var clearCount = 0

    init(orderIds: [String]) {
        self.orderIds = orderIds
    }

    func loadOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: orderIds)
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        changes.append(change)
        return UserOrder(id: "1", nfts: change.apply(to: orderIds))
    }

    func clearOrder() async throws -> UserOrder {
        clearCount += 1
        return UserOrder(id: "1", nfts: [])
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
