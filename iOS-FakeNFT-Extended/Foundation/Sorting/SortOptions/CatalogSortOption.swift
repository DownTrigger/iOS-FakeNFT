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
