import SwiftUI

enum CatalogLocalizedText {
    case empty
    case collectionEmpty
    case collectionAuthor
    case loadError

    var key: LocalizedStringKey {
        switch self {
        case .empty:
            "Catalog.empty"
        case .collectionEmpty:
            "Catalog.collectionEmpty"
        case .collectionAuthor:
            "Catalog.collectionAuthor"
        case .loadError:
            "Error.loadData"
        }
    }

    var text: String {
        switch self {
        case .empty:
            String(localized: "Catalog.empty")
        case .collectionEmpty:
            String(localized: "Catalog.collectionEmpty")
        case .collectionAuthor:
            String(localized: "Catalog.collectionAuthor")
        case .loadError:
            String(localized: "Error.loadData")
        }
    }
}
