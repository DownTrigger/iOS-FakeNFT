//
//  NFTCollectionNavigationLink.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionNavigationLink: View {
    let user: UserModel
    
    // Временно для разработки экрана
    private let nftCount = 3
    
    var body: some View {
        NavigationLink {
            NFTCollectionView(user: user)
        } label: {
            HStack {
                Text(
                    String(
                        format: NSLocalizedString(
                            "nft_collection.count",
                            comment: ""
                        ),
                        "\(nftCount)" // позже заменить на user.nftCollection.count
                    )
                )
                .font(.bold22)
                
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .font(.system(size: 22, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.fnText)
        .buttonStyle(.plain)
    }
}

#Preview("Alex") {
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            NFTCollectionNavigationLink(user: statistic.user)
        }
    }
}
