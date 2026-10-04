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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(.icBack)
                        .foregroundStyle(Color(.fnText))
                }
            }
        }
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

private struct FavouriteNFTCell: View {
    let model: NftGridCellModel
    let onLike: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: model.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(.imgNFTPlaceholder).resizable().scaledToFill()
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                LikeButton(isLiked: model.isLiked, action: onLike)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.bold17)
                    .foregroundStyle(Color(.fnText))
                    .lineLimit(1)

                RatingView(rating: model.rating)

                Text(model.priceText)
                    .font(.medium10)
                    .foregroundStyle(Color(.fnText))
            }

            Spacer(minLength: 0)
        }
    }
}
