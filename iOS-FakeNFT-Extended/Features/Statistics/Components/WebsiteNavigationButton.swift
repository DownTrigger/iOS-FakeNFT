//
//  WebsiteNavigationButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct WebsiteNavigationButton: View {
    @Environment(Router<StatisticsRoute>.self) private var router

    let url: URL

    var body: some View {
        Button {
            router.push(.website(url))
        } label: {
            Text(StatisticLocalizedText.openUserWebsite.key)
                .font(.regular15)
                .tracking(-0.24)
                .foregroundStyle(Color(.fnText))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.fnText, lineWidth: 1)
                }
        }
    }
}

#Preview {
    if let url = URL(string: "https://www.apple.com") {
        WebsiteNavigationButton(url: url)
            .padding()
            .environment(Router<StatisticsRoute>())
    }
}
