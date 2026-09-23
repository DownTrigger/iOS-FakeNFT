//
//  PrimaryButtonLocalizedText.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

enum PrimaryButtonLocalizedText {
    case login
    case register
    case resetPassword
    case pay
    case save
    
    var key: LocalizedStringKey {
        switch self {
        case .login:
            "button.login"
        case .register:
            "button.register"
        case .resetPassword:
            "button.reset_password"
        case .pay:
            "button.pay"
        case .save:
            "button.save"
        }
    }
}
