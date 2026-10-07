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

    var alert: AlertModel?

    private let user: UserModel
    private let nftService: NftService
    private let userState: UserState
    private let userDefaultsService: UserDefaultsService

    private static let sortOptionKey = "myNFTs.sortOption"

    init(
        user: UserModel,
        nftService: NftService,
        userState: UserState,
        userDefaultsService: UserDefaultsService
    ) {
        let saved = userDefaultsService.string(forKey: Self.sortOptionKey)
        self.sortOption = CartSortOption(rawValue: saved ?? "") ?? .byRating
        self.user = user
        self.nftService = nftService
        self.userState = userState
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
