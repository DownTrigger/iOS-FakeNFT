//
//  UserStatisticDetailView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct UserStatisticDetailView: View {
    let user: UserModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    UserInformationView(user: user)
                        .padding(.top, 20)
                    
                    if let website = user.userWebSite,
                       !website.isEmpty,
                       let url = URL(string: website) {
                        WebsiteNavigationButton(url: url)
                            .padding(.top, 28)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                NFTCollectionNavigationLink(user: user)
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(false)
    }
}

#Preview("Alex — Website") {
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            UserStatisticDetailView(user: statistic.user)
        }
    }
}
