import Foundation
import Observation

@MainActor
@Observable
final class FavouriteNFTsViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    var alert: AlertModel?

    private let nftService: NftService
    private let profileService: UserProfileService
    private let userState: UserState

    init(nftService: NftService, profileService: UserProfileService, userState: UserState) {
        self.nftService = nftService
        self.profileService = profileService
        self.userState = userState
    }

    var displayedNfts: [Nft] {
        guard case .loaded(let nfts) = state else { return [] }
        return nfts.filter { userState.isLiked($0.id) }
    }

    func cellModel(for nft: Nft) -> NftGridCellModel {
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

    func toggleLike(_ nft: Nft) async {
        do {
            try await userState.toggleLike(nft.id)
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: CatalogLocalizedText.likeError.resource) { [weak self] in
                Task { await self?.toggleLike(nft) }
            }
        }
    }

    func loadNfts() async {
        guard state.canStartLoading else { return }
        state = .loading
        do {
            async let profile = profileService.loadProfile()
            async let likes: Void = userState.loadIfNeeded()
            let (loadedProfile, _) = try await (profile, likes)
            let loaded = try await nftService.loadNfts(ids: loadedProfile.likes)
            state = .loaded(loaded)
        } catch {
            guard !error.isCancellation else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: CatalogLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.loadNfts() }
            }
        }
    }
}
