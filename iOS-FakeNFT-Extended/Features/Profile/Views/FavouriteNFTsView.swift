import SwiftUI

struct FavouriteNFTsView: View {
    @State private var viewModel: FavouriteNFTsViewModel
    @State private var selectedNft: Nft?
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible(), spacing: 7), GridItem(.flexible())]

    init(nftService: NftService, profileService: UserProfileService, userState: UserState) {
        _viewModel = State(initialValue: FavouriteNFTsViewModel(
            nftService: nftService,
            profileService: profileService,
            userState: userState
        ))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppLoadingView()
            case .loaded:
                if viewModel.displayedNfts.isEmpty {
                    EmptyStateView(message: ProfileLocalizedText.favouriteNFTsEmpty.key)
                } else {
                    nftGrid
                }
            case .failed:
                if viewModel.alert == nil {
                    ErrorStateView(message: ProfileLocalizedText.favouriteNFTsLoadError.key) {
                        Task { await viewModel.loadNfts() }
                    }
                }
            }
        }
        .appAlert(item: $viewModel.alert)
        .navigationTitle(ScreenLocalizedText.favouriteNFTs.key)
        .navigationBarTitleDisplayMode(.inline)
        .backButton { dismiss() }
        .toolbar(.hidden, for: .tabBar)
        .background(Color(.fnBackground))
        .task { await viewModel.loadNfts() }
        .sheet(item: $selectedNft) { nft in
            NftDetailView(nftId: nft.id)
        }
    }

    private var nftGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.displayedNfts, id: \.id) { nft in
                    FavouriteNFTCell(
                        model: viewModel.cellModel(for: nft),
                        onLike: { Task { await viewModel.toggleLike(nft) } }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { selectedNft = nft }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
}

private struct FavouritePreviewNftService: NftService {
    func loadNft(id: String) async throws -> Nft {
        Nft(
            id: id,
            name: "April",
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
            description: "Test NFT",
            rating: 3,
            price: 1.78,
            author: "Lin Gen"
        )
    }
}

#Preview {
    NavigationStack {
        FavouriteNFTsView(
            nftService: FavouritePreviewNftService(),
            profileService: ProfilePreviewUserProfileService(),
            userState: UserState(
                profileService: ProfilePreviewUserProfileService(),
                orderService: ProfilePreviewUserOrderService()
            )
        )
    }
}
