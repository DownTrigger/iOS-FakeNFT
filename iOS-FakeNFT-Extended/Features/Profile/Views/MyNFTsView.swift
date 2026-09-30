//
//  MyNFTsView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct MyNFTsView: View {
    @State private var viewModel: MyNFTsViewModel
    @State private var showSortSheet = false
    @Environment(\.dismiss) private var dismiss

    init(nftIds: [String], likedIds: [String], username: String, nftService: NftService) {
        _viewModel = State(initialValue: MyNFTsViewModel(
            nftIds: nftIds,
            likedIds: likedIds,
            username: username,
            nftService: nftService
        ))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppLoadingView()
            case .loaded:
                if viewModel.sortedNfts.isEmpty {
                    EmptyStateView(message: "У вас ещё нет NFT")
                } else {
                    nftList
                }
            case .failed:
                EmptyStateView(message: "Не удалось загрузить NFT")
            }
        }
        .navigationTitle("Мои NFT")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color(.fnText))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationSortButton {
                    withAnimation { showSortSheet = true }
                }
            }
        }
        .sortSheet(
            isPresented: $showSortSheet,
            options: MyNFTsSortOption.allCases
        ) { option in
            viewModel.setSortOption(option)
        }
        .background(Color(.fnBackground))
        .task { await viewModel.loadNfts() }
    }

    private var nftList: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.sortedNfts, id: \.id) { nft in
                    MyNFTListCell(
                        nft: nft,
                        isLiked: viewModel.isLiked(nft),
                        username: viewModel.username,
                        onLike: { viewModel.toggleLike(nft) }
                    )
                    .padding(.leading, 16)
                    .padding(.trailing, 39)
                }
            }
            .padding(.top, 20)
        }
    }
}

private struct PreviewNftService: NftService {
    func loadNft(id: String) async throws -> Nft {
        Nft(
            id: id,
            name: ["April", "Spring", "Lilo"].randomElement()!,
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!],
            description: "Test NFT",
            rating: Int.random(in: 1...5),
            price: 1.78
        )
    }
}

#Preview {
    NavigationStack {
        MyNFTsView(
            nftIds: ["1", "2", "3"],
            likedIds: ["1"],
            username: "John Doe",
            nftService: PreviewNftService()
        )
    }
    .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
}
