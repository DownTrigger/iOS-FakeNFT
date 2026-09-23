//
//  CartSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

/// Sorting options for cart and profile screens
enum CartSortOption: String, SortOptionProtocol {
    case byTitle
    case byRating
    case byPrice
    
    var id: String {
        rawValue
    }
    
    var title: SortingLocalizedText {
        switch self {
        case .byTitle:
            return .sortByTitle
        case .byRating:
            return .sortByRating
        case .byPrice:
            return .sortByPrice
        }
    }
}
