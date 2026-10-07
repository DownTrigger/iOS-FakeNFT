//
//  NFTCollectionView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 25.09.2026.
//

import SwiftUI

struct NFTCollectionView: View {
    let nfts: [String]

    @Environment(Router<StatisticsRoute>.self) private var router
    @State private var viewModel: NFTCollectionViewModel
    @State private var selectedCell: NftGridCellModel?

    private let columns = [
        GridItem(.flexible(), spacing: 9, alignment: .top),
        GridItem(.flexible(), spacing: 9, alignment: .top),
        GridItem(.flexible(), spacing: 9, alignment: .top)
    ]

    init(nfts: [String], nftService: NftService, userState: UserState) {
        self.nfts = nfts
        _viewModel = State(
            initialValue: NFTCollectionViewModel(
                nftIds: nfts,
                nftService: nftService,
                userState: userState
            )
        )
    }

    var body: some View {
        ScrollView {
            content
        }
        .background(Color(.fnBackground))
        .navigationTitle(StatisticLocalizedText.title.key)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .backButton { router.pop() }
        .task { await viewModel.loadNfts() }
        .appAlert(item: $viewModel.alert)
        .sheet(item: $selectedCell) { cell in
            NftDetailView(nftId: cell.id)
        }
    }

    @ViewBuilder
    private var content: some View {
        if nfts.isEmpty || viewModel.isEmpty {
            EmptyStateView(message: StatisticLocalizedText.emptyNftCollection.key)
        } else if viewModel.isFailed && viewModel.alert == nil {
            ErrorStateView(message: CatalogLocalizedText.loadError.key) {
                Task { await viewModel.loadNfts() }
            }
        } else if viewModel.isLoading {
            ProgressView()
                .tint(Color(.fnText))
                .frame(maxWidth: .infinity)
        } else {
            LazyVGrid(columns: columns, spacing: 28) {
                ForEach(viewModel.cells) { cell in
                    NftGridCell(
                        model: cell,
                        onLike: { Task { await viewModel.toggleLike(cell.id) } },
                        onCart: { Task { await viewModel.toggleCart(cell.id) } }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedCell = cell }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    let services = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    NavigationStack {
        NFTCollectionView(
            nfts: ["1", "2", "3"],
            nftService: services.nftService,
            userState: UserState(
                profileService: services.userProfileService,
                orderService: services.userOrderService
            )
        )
    }
    .environment(Router<StatisticsRoute>())
}
