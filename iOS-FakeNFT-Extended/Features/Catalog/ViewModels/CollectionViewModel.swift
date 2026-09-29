import Foundation

@MainActor
@Observable
final class CollectionViewModel {
    let collection: NftCollection
    private(set) var state: LoadingState<[Nft]> = .idle
    var alert: AlertModel?

    private let nftService: NftService

    var isLoading: Bool { state.isLoading }

    var isEmpty: Bool {
        guard case let .loaded(nfts) = state else { return false }
        return nfts.isEmpty
    }

    var cells: [NftGridCellModel] {
        guard case let .loaded(nfts) = state else { return [] }
        return nfts.map(Self.makeCellModel)
    }

    init(collection: NftCollection, nftService: NftService) {
        self.collection = collection
        self.nftService = nftService
    }

    func loadNfts() async {
        guard state.canStartLoading else { return }
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
            alert = .retryError(title: CatalogLocalizedText.loadError.text) { [weak self] in
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

    private static func makeCellModel(from nft: Nft) -> NftGridCellModel {
        NftGridCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            priceText: PriceFormatter.string(from: nft.price),
            isLiked: false,
            isInCart: false
        )
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

    var canStartLoading: Bool {
        switch self {
        case .idle, .failed:
            true
        case .loading, .loaded:
            false
        }
    }
}
