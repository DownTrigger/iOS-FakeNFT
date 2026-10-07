//
//  MyNFTsView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct MyNFTsView: View {
    private static let sortOptionKey = "myNFTs.sortOption"

    @State private var viewModel: MyNFTsViewModel
    @State private var showSortSheet = false
    @AppStorage(Self.sortOptionKey) private var sortOption: NftSortOption = .byRating
    @Environment(\.dismiss) private var dismiss

    init(
        user: UserModel,
        nftService: NftService,
        userState: UserState
    ) {
        _viewModel = State(initialValue: MyNFTsViewModel(
            user: user,
            nftService: nftService,
            userState: userState
        ))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppLoadingView()
            case .loaded:
                if viewModel.sortedNfts.isEmpty {
                    EmptyStateView(message: ProfileLocalizedText.myNFTsEmpty.key)
                } else {
                    nftList
                }
            case .failed:
                if viewModel.alert == nil {
                    ErrorStateView(message: ProfileLocalizedText.myNFTsLoadError.key) {
                        Task { await viewModel.loadNfts() }
                    }
                }
            }
        }
        .appAlert(item: $viewModel.alert)
        .navigationTitle(ScreenLocalizedText.myNFTs.key)
        .navigationBarTitleDisplayMode(.inline)
        .backButton { dismiss() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    showSortSheet = true
                }
            }
        }
        .sortSheet(
            isPresented: $showSortSheet,
            options: [NftSortOption.byPrice, .byRating, .byTitle]
        ) { option in
            sortOption = option
        }
        .task(id: sortOption) { viewModel.applySort(sortOption) }
        .toolbar(.hidden, for: .tabBar)
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
                        isLikePending: viewModel.isLikePending(nft),
                        onLike: { Task { await viewModel.toggleLike(nft) } }
                    )
                    .padding(.leading, 16)
                    .padding(.trailing, 23)
                }
            }
            .padding(.top, 36)
        }
    }
}

private struct PreviewNftService: NftService {
    func loadNft(id: String) async throws -> Nft {
        Nft(
            id: id,
            name: ["April", "Spring", "Lilo"].randomElement() ?? "April",
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
            description: "Test NFT",
            rating: Int.random(in: 1...5),
            price: 1.78,
            author: "Lin Gen"
        )
    }
}

#Preview {
    NavigationStack {
        MyNFTsView(
            user: UserModel(
                avatar: nil,
                username: "John Doe",
                bio: "",
                userWebSite: nil,
                nfts: ["1", "2", "3"],
                likes: ["1"]
            ),
            nftService: PreviewNftService(),
            userState: UserState(
                profileService: ProfilePreviewUserProfileService(),
                orderService: ProfilePreviewUserOrderService()
            )
        )
    }
    .environment(ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    ))
}
