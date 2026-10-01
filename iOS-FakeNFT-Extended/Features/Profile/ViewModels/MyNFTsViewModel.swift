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
    private(set) var sortOption: MyNFTsSortOption

    private let nftIds: [String]
    private var likedIds: Set<String>
    let username: String
    private let nftService: NftService

    private static let sortOptionKey = "myNFTs.sortOption"

    init(nftIds: [String], likedIds: [String], username: String, nftService: NftService) {
        let saved = UserDefaults.standard.string(forKey: Self.sortOptionKey)
        self.sortOption = MyNFTsSortOption(rawValue: saved ?? "") ?? .byRating
        self.nftIds = nftIds
        self.likedIds = Set(likedIds)
        self.username = username
        self.nftService = nftService
    }
    
    var sortedNfts: [Nft] {
        guard case .loaded(let nfts) = state else { return [] }
        switch sortOption {
        case .byPrice:  return nfts.sorted { $0.price < $1.price }
        case .byRating: return nfts.sorted { $0.rating > $1.rating }
        case .byName:   return nfts.sorted { $0.name < $1.name }
        }
    }
    
    func setSortOption(_ option: MyNFTsSortOption) {
        sortOption = option
        UserDefaults.standard.set(option.rawValue, forKey: Self.sortOptionKey)
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
    }
    
    func loadNfts() async {
        guard case .idle = state else { return }
        state = .loading
        do {
            var loaded: [Nft] = []
            try await withThrowingTaskGroup(of: Nft.self) { group in
                for id in nftIds {
                    group.addTask {
                        try await self.nftService.loadNft(id: id)
                    }
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
