//
//  NFTCollectionNavigationLink.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionNavigationLink: View {
    @Environment(ServicesAssembly.self) private var services
    @Environment(UserState.self) private var userState

    let nfts: [String]

    var body: some View {
        NavigationLink {
            NFTCollectionView(nfts: nfts, nftService: services.nftService, userState: userState)
        } label: {
            HStack {
                Text(StatisticLocalizedText.collectionCount(nfts.count).key)
                .font(.bold17)

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
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            NFTCollectionNavigationLink(nfts: statistic.nfts)
        }
    }
    .environment(services)
    .environment(UserState(profileService: services.userProfileService, orderService: services.userOrderService))
}
