//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionView: View {
    let user: UserModel
    let nfts: [String]

    @State private var viewModel: NFTCollectionViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    init(user: UserModel, nfts: [String]) {
        self.user = user
        self.nfts = nfts
        _viewModel = State(
            initialValue: NFTCollectionViewModel(
                networkClient: DefaultNetworkClient()
            )
        )
    }

    var body: some View {
        ScrollView {
            if nfts.isEmpty {
                EmptyStateView(
                    message: NSLocalizedString(
                        "stat_nft_emptyCollection", //не могу использовать enum, тк EmptyStateView принимает String
                        comment: ""
                    )
                )
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.nftItems) { model in
                        NftGridCell(
                            model: model,
                            onLike: {
                                // обработка Like
                            },
                            onCart: {
                                // обработка Cart
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(StatisticLocalizedText.title.key)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.load(nftIDs: nfts)
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.fnText)
                        .frame(width: 30, height: 30)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        if let statistic = StatisticsViewModel.preview.statistics.first(
            where: { $0.user.username == "Alex" }
        ) {
            NFTCollectionView(
                user: statistic.user,
                nfts: statistic.nfts
            )
        }
    }
}
