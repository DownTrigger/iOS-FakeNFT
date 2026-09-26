//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionView: View {
    let user: UserModel
    
    // Временные мок-данные. Заменить на загрузку
    private let nftItems: [NftGridCellModel] = NftGridCellModel.preview
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(nftItems) { model in
                    NftGridCell(
                        model: model,
                        onLike: {
                            // TODO: обработка Like
                        },
                        onCart: {
                            // TODO: обработка Cart
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle(StatisticLocalizedText.title.key)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            NFTCollectionView(user: statistic.user)
        }
    }
}
