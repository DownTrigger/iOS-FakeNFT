import Foundation

protocol UserOrderService: Sendable {
    func loadOrder() async throws -> UserOrder
    func updateNfts(_ change: IdChange) async throws -> UserOrder
    func clearOrder() async throws -> UserOrder
}

actor UserOrderServiceImpl: UserOrderService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadOrder() async throws -> UserOrder {
        try await networkClient.send(request: UserOrderRequest())
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        let order = try await loadOrder()
        let nfts = change.apply(to: order.nfts)
        guard nfts != order.nfts else {
            return order
        }
        return try await networkClient.send(request: UserOrderUpdateRequest(nfts: nfts))
    }

    func clearOrder() async throws -> UserOrder {
        try await networkClient.send(request: UserOrderUpdateRequest(nfts: []))
    }
}
