//
//  StatisticNFTCollectionLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

enum StatisticLocalizedText {
    case title
    case collectionCount
    case openUserWebsite
    
    var key: LocalizedStringKey {
        switch self {
        case .title:
            "nft_collection.title"
        case .collectionCount:
            "nft_collection.count"
        case .openUserWebsite:
            "website.open_user"
        }
    }
}
