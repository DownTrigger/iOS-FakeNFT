import Foundation

@MainActor
@Observable
final class CollectionViewModel {
    let collection: NftCollection
    private(set) var state: LoadingState<[Nft]> = .idle
    var alert: AlertModel?

    private let nftService: NftService
    private let userState: UserState

    var isLoading: Bool { state.isLoading }

    var isEmpty: Bool {
        guard case let .loaded(nfts) = state else { return false }
        return nfts.isEmpty
    }

    var cells: [NftGridCellModel] {
        guard case let .loaded(nfts) = state else { return [] }
        return nfts.map(makeCellModel)
    }

    init(collection: NftCollection, nftService: NftService, userState: UserState) {
        self.collection = collection
        self.nftService = nftService
        self.userState = userState
    }

    func loadNfts() async {
        guard state.canStartLoading else { return }
        state = .loading
        do {
            async let nfts = nftService.loadNfts(ids: collection.nfts)
            async let user: Void = userState.loadIfNeeded()
            let (loaded, _) = try await (nfts, user)
            state = .loaded(loaded)
        } catch {
            guard !error.isCancellation else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: CatalogLocalizedText.loadError.text) { [weak self] in
                Task { await self?.loadNfts() }
            }
        }
    }

    func toggleLike(_ id: String) async {
        do {
            try await userState.toggleLike(id)
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: CatalogLocalizedText.likeError.text) { [weak self] in
                Task { await self?.toggleLike(id) }
            }
        }
    }

    func toggleCart(_ id: String) async {
        do {
            try await userState.toggleCart(id)
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: CatalogLocalizedText.cartError.text) { [weak self] in
                Task { await self?.toggleCart(id) }
            }
        }
    }

    private func makeCellModel(from nft: Nft) -> NftGridCellModel {
        NftGridCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            priceText: PriceFormatter.string(from: nft.price),
            isLiked: userState.isLiked(nft.id),
            isInCart: userState.isInCart(nft.id),
            isLikePending: userState.isLikePending(nft.id),
            isCartPending: userState.isCartPending(nft.id)
        )
    }
}
