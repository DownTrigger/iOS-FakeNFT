import Foundation
import Observation

@MainActor
@Observable
final class FavouriteNFTsViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    private var likedIds: Set<String>
    private let user: UserModel
    private let nftService: NftService
    private let userService: UserService

    init(user: UserModel, nftService: NftService, userService: UserService) {
        self.user = user
        self.likedIds = Set(user.likes)
        self.nftService = nftService
        self.userService = userService
    }

    var displayedNfts: [Nft] {
        guard case .loaded(let nfts) = state else { return [] }
        return nfts.filter { likedIds.contains($0.id) }
    }

    func isLiked(_ nft: Nft) -> Bool {
        likedIds.contains(nft.id)
    }

    func cellModel(for nft: Nft) -> NftGridCellModel {
        NftGridCellModel(
            id: nft.id,
            imageURL: nft.images.first,
            name: nft.name,
            rating: nft.rating,
            priceText: PriceFormatter.string(from: nft.price),
            isLiked: isLiked(nft),
            isInCart: false
        )
    }

    func toggleLike(_ nft: Nft) {
        if likedIds.contains(nft.id) {
            likedIds.remove(nft.id)
        } else {
            likedIds.insert(nft.id)
        }
        let updatedUser = UserModel(
            avatar: user.avatar,
            username: user.username,
            bio: user.bio,
            userWebSite: user.userWebSite,
            nfts: user.nfts,
            likes: Array(likedIds)
        )
        Task { _ = try? await userService.updateUser(updatedUser) }
    }

    func loadNfts() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            var loaded: [Nft] = []
            try await withThrowingTaskGroup(of: Nft.self) { group in
                for id in user.likes {
                    group.addTask { try await self.nftService.loadNft(id: id) }
                }
                for try await nft in group {
                    loaded.append(nft)
                }
            }
            state = .loaded(loaded)
        } catch {
            state = .failed(error)
        }
    }
}
