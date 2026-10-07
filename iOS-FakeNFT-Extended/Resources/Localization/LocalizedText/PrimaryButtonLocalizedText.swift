//
//  PrimaryButtonLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

enum PrimaryButtonLocalizedText {
    case pay
    case save

    var key: LocalizedStringKey {
        switch self {
        case .pay:
            "button.pay"
        case .save:
            "button.save"
        }
    }
}
