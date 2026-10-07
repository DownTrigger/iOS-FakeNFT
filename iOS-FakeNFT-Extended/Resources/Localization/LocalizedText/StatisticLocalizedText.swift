//
//  StatisticNFTCollectionLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

enum StatisticLocalizedText {
    case title
    case openUserWebsite
    case emptyNftCollection
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
        case .loadError:
            "stat_load_error"
        case .refreshError:
            "stat_refresh_error"
        }
    }
}
