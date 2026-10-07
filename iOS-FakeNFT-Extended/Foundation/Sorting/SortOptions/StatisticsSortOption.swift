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
