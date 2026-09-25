//
//  WebsiteNavigationButton.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct WebsiteNavigationButton: View {
    let url: URL
    
    var body: some View {
        NavigationLink {
            // WebView(url: url) Саша загрузит в девелоп общий WebView
        } label: {
            Text(StatisticLocalizedText.openUserWebsite.key)
                .font(.system(size: 15, weight: .regular))
                .tracking(-0.24)
                .frame(width: 343, height: 40)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.fnText, lineWidth: 1)
                }
        }
        .tint(.fnText)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WebsiteNavigationButton(
        url: URL(string: "https://www.apple.com")!
    )
    .padding()
}
