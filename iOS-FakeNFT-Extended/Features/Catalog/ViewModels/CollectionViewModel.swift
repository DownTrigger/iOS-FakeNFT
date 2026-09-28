import Foundation

@MainActor
@Observable
final class CollectionViewModel {
    let collection: NftCollection
    private(set) var state: LoadingState<[Nft]> = .idle
    var alert: AlertModel?

    private let nftService: NftService

    init(collection: NftCollection, nftService: NftService) {
        self.collection = collection
        self.nftService = nftService
    }

    func loadNfts() async {
        guard !state.isLoading else { return }
        state = .loading
        do {
            let loaded = try await Self.loadNfts(ids: collection.nfts, service: nftService)
            state = .loaded(collection.nfts.compactMap { loaded[$0] })
        } catch {
            guard !Self.isCancellation(error) else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: String(localized: "Error.loadData")) { [weak self] in
                Task { await self?.loadNfts() }
            }
        }
    }

    private static func loadNfts(ids: [String], service: NftService) async throws -> [String: Nft] {
        try await withThrowingTaskGroup(of: Nft.self) { group in
            for id in ids {
                group.addTask {
                    try await service.loadNft(id: id)
                }
            }
            var loaded: [String: Nft] = [:]
            for try await nft in group {
                loaded[nft.id] = nft
            }
            return loaded
        }
    }

    private static func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }
}

private extension LoadingState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}
