//
//  UserStatisticDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct UserStatisticDetailView: View {
    let statistic: UserStatisticItem

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    UserInformationView(user: statistic.user)
                        .padding(.top, 20)

                    if let website = statistic.user.userWebSite,
                       !website.isEmpty,
                       let url = URL(string: website) {
                        WebsiteNavigationButton(url: url)
                            .padding(.top, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                NFTCollectionNavigationLink(
                    user: statistic.user,
                    nfts: statistic.nfts
                )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(false)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview("Alex — Website") {
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            UserStatisticDetailView(statistic: statistic)
        }
    }
}
