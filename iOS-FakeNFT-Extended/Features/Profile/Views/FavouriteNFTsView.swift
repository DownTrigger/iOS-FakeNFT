import SwiftUI

struct FavouriteNFTsView: View {
    @State private var viewModel: FavouriteNFTsViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    init(user: UserModel, nftService: NftService, userService: UserService) {
        _viewModel = State(initialValue: FavouriteNFTsViewModel(
            user: user,
            nftService: nftService,
            userService: userService
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
                EmptyStateView(message: ProfileLocalizedText.favouriteNFTsLoadError.key)
            }
        }
        .navigationTitle(ScreenLocalizedText.favouriteNFTs.key)
        .navigationBarTitleDisplayMode(.inline)
        .backButton { dismiss() }
        .toolbar(.hidden, for: .tabBar)
        .background(Color(.fnBackground))
        .task { await viewModel.loadNfts() }
    }

    private var nftGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.displayedNfts, id: \.id) { nft in
                    FavouriteNFTCell(
                        model: viewModel.cellModel(for: nft),
                        onLike: { viewModel.toggleLike(nft) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
    }
}
