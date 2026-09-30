//
//  MyNFTsSortOption.swift
//  iOS-FakeNFT-Extended
//

enum MyNFTsSortOption: String, SortOptionProtocol, CaseIterable {
    case byPrice
    case byRating
    case byName
    
    var id: String { rawValue }
    
    var title: SortingLocalizedText {
        switch self {
        case .byPrice:
            return .sortByPrice
        case .byRating:
            return .sortByRating
        case .byName:
            return .sortByName
        }
    }
}
