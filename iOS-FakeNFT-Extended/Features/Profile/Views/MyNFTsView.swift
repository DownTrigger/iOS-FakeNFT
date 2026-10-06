//
//  MyNFTsView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct MyNFTsView: View {
    @State private var viewModel: MyNFTsViewModel
    @State private var showSortSheet = false
    @Environment(\.dismiss) private var dismiss

    init(
        user: UserModel,
        nftService: NftService,
        userService: UserService,
        userDefaultsService: UserDefaultsService
    ) {
        _viewModel = State(initialValue: MyNFTsViewModel(
            user: user,
            nftService: nftService,
            userService: userService,
            userDefaultsService: userDefaultsService
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
                EmptyStateView(message: ProfileLocalizedText.myNFTsLoadError.key)
            }
        }
        .navigationTitle(ScreenLocalizedText.myNFTs.key)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(.icBack)
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
            options: [CartSortOption.byPrice, .byRating, .byName]
        ) { option in
            viewModel.setSortOption(option)
        }
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
            name: ["April", "Spring", "Lilo"].randomElement() ?? "April",
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")!],
            description: "Test NFT",
            rating: Int.random(in: 1...5),
            price: 1.78,
            author: "Lin Gen"
        )
    }
}

private struct MyNFTsPreviewUserService: UserService {
    func loadUser() async throws -> UserModel { fatalError("preview only") }
    func updateUser(_ user: UserModel) async throws -> UserModel { user }
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
            userService: MyNFTsPreviewUserService(),
            userDefaultsService: UserDefaultsServiceImpl()
        )
    }
    .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl(), likesStorage: LikesStorageImpl()))
}
