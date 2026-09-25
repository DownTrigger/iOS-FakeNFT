//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionView: View {
    let user: UserModel
    
    var body: some View {
        ScrollView {
            // сетка изображений NFT пользователя
        }
        .navigationTitle(StatisticLocalizedText.title.key)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        let statistic = StatisticsViewModel.preview.statistics.first {
            $0.user.username == "Alex"
        }!
        
        NFTCollectionView(user: statistic.user)
    }
}

