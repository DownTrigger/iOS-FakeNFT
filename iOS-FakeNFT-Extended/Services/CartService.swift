import Foundation

protocol CartService: Sendable {
    func loadCart() async throws -> [Nft]
    func remove(nftId: String) async throws
    func clear() async throws
}

actor CartServiceImpl: CartService {
    private let orderService: UserOrderService
    private let nftService: NftService

    init(orderService: UserOrderService, nftService: NftService) {
        self.orderService = orderService
        self.nftService = nftService
    }

    func loadCart() async throws -> [Nft] {
        let order = try await orderService.loadOrder()
        return try await nftService.loadNfts(ids: order.nfts)
    }

    func remove(nftId: String) async throws {
        _ = try await orderService.updateNfts(.remove(nftId))
    }

    func clear() async throws {
        _ = try await orderService.clearOrder()
    }
}
