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

    var resource: LocalizedStringResource {
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
}
