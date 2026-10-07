import Foundation
import Observation

@MainActor
@Observable
final class MyNFTsViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    private(set) var sortOption: NftSortOption = .byRating

    var alert: AlertModel?

    private let user: UserModel
    private let nftService: NftService
    private let userState: UserState

    init(
        user: UserModel,
        nftService: NftService,
        userState: UserState
    ) {
        self.user = user
        self.nftService = nftService
        self.userState = userState
    }

    var sortedNfts: [Nft] {
        guard case .loaded(let nfts) = state else { return [] }
        return sortOption.sorted(nfts)
    }

    func applySort(_ option: NftSortOption) {
        sortOption = option
    }

    func isLiked(_ nft: Nft) -> Bool {
        userState.isLiked(nft.id)
    }

    func isLikePending(_ nft: Nft) -> Bool {
        userState.isLikePending(nft.id)
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
            async let nfts = nftService.loadNfts(ids: user.nfts)
            async let likes: Void = userState.loadIfNeeded()
            let (loaded, _) = try await (nfts, likes)
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
