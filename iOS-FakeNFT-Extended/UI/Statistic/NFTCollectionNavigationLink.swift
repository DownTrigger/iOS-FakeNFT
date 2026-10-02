//
//  NFTCollectionNavigationLink.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionNavigationLink: View {
    let user: UserModel
    let nfts: [String]

    var body: some View {
        NavigationLink {
            NFTCollectionView(user: user, nfts: nfts)
        } label: {
            HStack {
                Text(
                    String(
                        format: NSLocalizedString(
                            "nft_collection.count",
                            comment: ""
                        ),
                        String(nfts.count)
                    )
                )
                .font(.bold22)

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.system(size: 22, weight: .semibold))
            }
            .padding(16)
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
            NFTCollectionNavigationLink(
                user: statistic.user,
                nfts: statistic.nfts
            )
        }
    }
}
