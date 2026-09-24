//
//  StatisticsSortOption.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

enum StatisticsSortOption: String, SortOptionProtocol {
    case byName
    case byRating

    var id: String {
        rawValue
    }

    var title: SortingLocalizedText {
        switch self {
        case .byName:
            return .sortByName
        case .byRating:
            return .sortByRating
        }
    }
}
