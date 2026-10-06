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
        return try await loadNfts(ids: order.nfts)
    }

    func remove(nftId: String) async throws {
        _ = try await orderService.updateNfts(.remove(nftId))
    }

    func clear() async throws {
        _ = try await orderService.clearOrder()
    }

    // MARK: - Private

    private func loadNfts(ids: [String]) async throws -> [Nft] {
        let nftService = nftService
        let loaded = try await withThrowingTaskGroup(of: Nft.self) { group in
            for id in ids {
                group.addTask {
                    try await nftService.loadNft(id: id)
                }
            }
            var result: [String: Nft] = [:]
            for try await nft in group {
                result[nft.id] = nft
            }
            return result
        }
        return ids.compactMap { loaded[$0] }
    }
}
