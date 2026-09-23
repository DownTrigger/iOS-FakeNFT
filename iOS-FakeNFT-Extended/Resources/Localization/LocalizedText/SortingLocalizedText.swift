//
//  SortingLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

enum SortingLocalizedText {
    case sortByName
    case sortByTitle
    case sortByRating
    case sortByNFTCount
    case sortByPrice
    case close
    
    var key: LocalizedStringKey {
        switch self {
        case .sortByName:
            "sorting.sortByName"
        case .sortByTitle:
            "sorting.sortByTitle"
        case .sortByRating:
            "sorting.sortByRating"
        case .sortByNFTCount:
            "sorting.sortByNFTCount"
        case .sortByPrice:
            "sorting.sortByPrice"
        case .close:
            "sorting.close"
        }
    }
}
