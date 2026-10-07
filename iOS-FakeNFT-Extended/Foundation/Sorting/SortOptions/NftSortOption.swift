//
//  NftSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

/// Sorting options for cart and profile screens
enum NftSortOption: String, SortOptionProtocol, CaseIterable {
    case byTitle
    case byRating
    case byPrice

    var id: String {
        rawValue
    }

    var title: SortingLocalizedText {
        switch self {
        case .byTitle:
            .sortByTitle
        case .byRating:
            .sortByRating
        case .byPrice:
            .sortByPrice
        }
    }
}

extension NftSortOption {
    func sorted(_ nfts: [Nft]) -> [Nft] {
        switch self {
        case .byTitle:
            sortBy(nfts, keyPath: \.name)
        case .byRating:
            sortBy(nfts, keyPath: \.rating, ascending: false)
        case .byPrice:
            sortBy(nfts, keyPath: \.price, ascending: false)
        }
    }
}
