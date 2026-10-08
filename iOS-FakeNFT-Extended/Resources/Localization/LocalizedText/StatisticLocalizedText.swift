import SwiftUI

enum StatisticLocalizedText {
    case title
    case openUserWebsite
    case emptyNftCollection
    case emptyUsers
    case loadError
    case refreshError

    var key: LocalizedStringKey {
        switch self {
        case .title:
            "nft_collection.title"
        case .openUserWebsite:
            "website.open_user"
        case .emptyNftCollection:
            "stat_nft_emptyCollection"
        case .emptyUsers:
            "stat_empty_users"
        case .loadError:
            "stat_load_error"
        case .refreshError:
            "stat_refresh_error"
        }
    }

    var resource: LocalizedStringResource {
        switch self {
        case .title:
            "nft_collection.title"
        case .openUserWebsite:
            "website.open_user"
        case .emptyNftCollection:
            "stat_nft_emptyCollection"
        case .emptyUsers:
            "stat_empty_users"
        case .loadError:
            "stat_load_error"
        case .refreshError:
            "stat_refresh_error"
        }
    }
}
