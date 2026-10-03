//
//  CartSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

/// Sorting options for cart and profile screens
enum CartSortOption: String, SortOptionProtocol, CaseIterable {
    case byTitle
    case byRating
    case byPrice
    case byName

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
        case .byName:
            .sortByName
        }
    }
}
