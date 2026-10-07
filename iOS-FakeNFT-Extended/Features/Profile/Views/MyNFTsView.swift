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
        userState: UserState,
        userDefaultsService: UserDefaultsService
    ) {
        _viewModel = State(initialValue: MyNFTsViewModel(
            user: user,
            nftService: nftService,
            userState: userState,
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
        .appAlert(item: $viewModel.alert)
        .navigationTitle(ScreenLocalizedText.myNFTs.key)
        .navigationBarTitleDisplayMode(.inline)
        .backButton { dismiss() }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                        isLikePending: viewModel.isLikePending(nft),
                        onLike: { Task { await viewModel.toggleLike(nft) } }
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
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
            description: "Test NFT",
            rating: Int.random(in: 1...5),
            price: 1.78,
            author: "Lin Gen"
        )
    }
}

struct ProfilePreviewUserProfileService: UserProfileService {
    private let profile = UserProfile(
        id: "1",
        name: "John Doe",
        description: "",
        website: nil,
        avatar: nil,
        nfts: ["1", "2", "3"],
        likes: ["1"]
    )

    func loadProfile() async throws -> UserProfile { profile }
    func updateLikes(_ change: IdChange) async throws -> UserProfile { profile }
    func updateProfile(
        name: String,
        description: String,
        avatar: String?,
        website: String?
    ) async throws -> UserProfile {
        profile
    }
}

struct ProfilePreviewUserOrderService: UserOrderService {
    private let order = UserOrder(id: "1", nfts: [])

    func loadOrder() async throws -> UserOrder { order }
    func updateNfts(_ change: IdChange) async throws -> UserOrder { order }
    func clearOrder() async throws -> UserOrder { order }
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
            ),
            userDefaultsService: UserDefaultsServiceImpl()
        )
    }
    .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl(), likesStorage: LikesStorageImpl()))
}
