import SwiftUI

enum CatalogLocalizedText {
    case empty
    case collectionEmpty
    case collectionAuthor
    case loadError
    case likeError
    case cartError

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
        case .likeError:
            "Catalog.likeError"
        case .cartError:
            "Catalog.cartError"
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
        case .likeError:
            String(localized: "Catalog.likeError")
        case .cartError:
            String(localized: "Catalog.cartError")
        }
    }
}
