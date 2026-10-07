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
                    ReusableUserInformationView(user: statistic.user)
                        .padding(.top, 20)

                    if let website = statistic.user.userWebSite,
                       !website.isEmpty,
                       let url = URL(string: website) {
                        WebsiteNavigationButton(url: url)
                            .padding(.top, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                NFTCollectionNavigationLink(nfts: statistic.nfts)
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
        if let user = PreviewUserService.users.first(where: { $0.name == "Alex" }) {
            let statistic = UserStatisticItem(position: 1, response: user)
            UserStatisticDetailView(statistic: statistic)
        }
    }
    .environment(Router<StatisticsRoute>())
}
