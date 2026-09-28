//
//  ScreenLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

enum ScreenLocalizedText {
    case sorting
    case profilePhoto

    var key: LocalizedStringKey {
        switch self {
        case .sorting:
            "sorting.sorting"
        case .profilePhoto:
            "sorting.profilePhoto"
        }
    }
}
