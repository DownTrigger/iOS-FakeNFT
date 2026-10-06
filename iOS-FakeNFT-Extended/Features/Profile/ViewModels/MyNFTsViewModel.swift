//
//  MyNFTsViewModel.swift
//  iOS-FakeNFT-Extended
//

import Foundation
import Observation

@MainActor
@Observable
final class MyNFTsViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    private(set) var sortOption: CartSortOption

    private let user: UserModel
    private var likedIds: Set<String>
    var username: String { user.username }
    private let nftService: NftService
    private let userService: UserService
    private let userDefaultsService: UserDefaultsService

    private static let sortOptionKey = "myNFTs.sortOption"

    init(
        user: UserModel,
        nftService: NftService,
        userService: UserService,
        userDefaultsService: UserDefaultsService
    ) {
        let saved = userDefaultsService.string(forKey: Self.sortOptionKey)
        self.sortOption = CartSortOption(rawValue: saved ?? "") ?? .byRating
        self.user = user
        self.likedIds = Set(user.likes)
        self.nftService = nftService
        self.userService = userService
        self.userDefaultsService = userDefaultsService
    }

    var sortedNfts: [Nft] {
        guard case .loaded(let nfts) = state else { return [] }
        switch sortOption {
        case .byPrice:          return sortBy(nfts, keyPath: \.price)
        case .byRating:         return sortBy(nfts, keyPath: \.rating)
        case .byName, .byTitle: return sortBy(nfts, keyPath: \.name)
        }
    }

    func setSortOption(_ option: CartSortOption) {
        sortOption = option
        userDefaultsService.set(option.rawValue, forKey: Self.sortOptionKey)
    }

    func isLiked(_ nft: Nft) -> Bool {
        likedIds.contains(nft.id)
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
            let loaded = try await nftService.loadNfts(ids: user.nfts)
            state = .loaded(loaded)
        } catch {
            state = .failed(error)
        }
    }
}
