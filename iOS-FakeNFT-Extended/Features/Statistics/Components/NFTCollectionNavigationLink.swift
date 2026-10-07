//
//  NFTCollectionNavigationLink.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionNavigationLink: View {
    @Environment(Router<StatisticsRoute>.self) private var router

    let nfts: [String]

    var body: some View {
        Button {
            router.push(.nftCollection(nfts))
        } label: {
            HStack {
                Text(StatisticLocalizedText.collectionCount(nfts.count).key)

                Spacer()

                Image(systemName: "chevron.right")
            }
            .font(.bold17)
            .padding(16)
            .contentShape(Rectangle())
        }
        .foregroundStyle(.fnText)
        .buttonStyle(.plain)
    }
}

#Preview("Alex") {
    NavigationStack {
        if let user = PreviewUserService.users.first(where: { $0.name == "Alex" }) {
            let statistic = UserStatisticItem(position: 1, response: user)
            NFTCollectionNavigationLink(nfts: statistic.nfts)
        }
    }
    .environment(Router<StatisticsRoute>())
}
