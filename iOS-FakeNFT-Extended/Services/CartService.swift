import Foundation

protocol CartService: Sendable {
    func loadCart() async throws -> [Nft]
    func updateOrder(nftIds: [String]) async throws
}

actor CartServiceImpl: CartService {
    private let networkClient: NetworkClient
    private let nftService: NftService
    private let orderUpdater: CartOrderUpdater

    init(networkClient: NetworkClient, nftService: NftService, orderUpdater: CartOrderUpdater) {
        self.networkClient = networkClient
        self.nftService = nftService
        self.orderUpdater = orderUpdater
    }

    func loadCart() async throws -> [Nft] {
        let order: Order = try await networkClient.send(request: OrderRequest())
        return try await loadNfts(ids: order.nfts)
    }

    func updateOrder(nftIds: [String]) async throws {
        try await orderUpdater.updateOrder(nftIds: nftIds)
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
