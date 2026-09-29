import Foundation

protocol CartService: Sendable {
    func loadCart() async throws -> [CartNft]
}

actor CartServiceImpl: CartService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCart() async throws -> [CartNft] {
        let order: Order = try await networkClient.send(request: OrderRequest())
        return try await loadNfts(ids: order.nfts)
    }

    // MARK: - Private

    private func loadNfts(ids: [String]) async throws -> [CartNft] {
        let networkClient = networkClient
        let loaded = try await withThrowingTaskGroup(of: CartNft.self) { group in
            for id in ids {
                group.addTask {
                    try await networkClient.send(request: NFTRequest(id: id))
                }
            }
            var result: [String: CartNft] = [:]
            for try await nft in group {
                result[nft.id] = nft
            }
            return result
        }
        return ids.compactMap { loaded[$0] }
    }
}
