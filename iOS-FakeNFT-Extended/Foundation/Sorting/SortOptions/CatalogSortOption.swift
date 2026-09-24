//
//  CatalogSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

enum CatalogSortOption: String, SortOptionProtocol {
    case byTitle
    case byNftCount

    var id: String {
        rawValue
    }

    var title: SortingLocalizedText {
        switch self {
        case .byTitle:
            return .sortByTitle
        case .byNftCount:
            return .sortByNFTCount
        }
    }
}
