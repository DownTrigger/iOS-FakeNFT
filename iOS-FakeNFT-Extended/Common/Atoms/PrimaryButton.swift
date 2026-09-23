//
//  PrimaryButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 23.09.2026.
//

import SwiftUI

enum LocalizedText {
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

struct PrimaryButton: View {
    let title: LocalizedText
    let action: () -> Void
    var isDisabled: Bool = false
    var body: some View {
        Button(action: action) {
            Text(title.key)
                .font(.bold17)
                .foregroundStyle(Color(.fnBackground))
                .frame(width: 343, height: 60)
                .background(Color(.fnText))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: .login) {
            print("Login")
        }
        PrimaryButton(title: .register) {
            print("Register")
        }
        PrimaryButton(title: .pay) {
            print("Pay")
        }
        PrimaryButton(title: .save) {
            print("Save")
        }
        PrimaryButton(title: .resetPassword) {
            print("Reset password")
        }
        PrimaryButton(title: .login, action: {}, isDisabled: true)
    }
}

#Preview("Dark Mode") {
    PrimaryButton(
        title: .login,
        action: {}
    )
    .preferredColorScheme(.dark)
}
