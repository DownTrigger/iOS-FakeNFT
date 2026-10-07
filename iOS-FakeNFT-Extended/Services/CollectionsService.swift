import Foundation

protocol CollectionsService: Sendable {
    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection]
    func loadCollection(id: String) async throws -> NftCollection
}

actor CollectionsServiceImpl: CollectionsService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection] {
        let request = CollectionsRequest(page: page, size: size, sortBy: sortBy)
        return try await networkClient.send(request: request)
    }

    func loadCollection(id: String) async throws -> NftCollection {
        let request = CollectionRequest(id: id)
        return try await networkClient.send(request: request)
    }
}
