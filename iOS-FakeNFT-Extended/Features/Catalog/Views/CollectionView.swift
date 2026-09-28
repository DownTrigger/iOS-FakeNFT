import SwiftUI

struct CollectionView: View {
    private static let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 9), count: 3)

    @State private var viewModel: CollectionViewModel

    init(collection: NftCollection, nftService: NftService) {
        _viewModel = State(initialValue: CollectionViewModel(collection: collection, nftService: nftService))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CollectionHeaderView(collection: viewModel.collection, onAuthorTap: {})
                nfts
            }
            .padding(.bottom, 16)
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.fnBackground))
        .task { await viewModel.loadNfts() }
        .appAlert(item: $viewModel.alert)
    }

    @ViewBuilder
    private var nfts: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(Color(.fnText))
                .frame(maxWidth: .infinity)
        } else if viewModel.isEmpty {
            EmptyStateView(message: String(localized: "Catalog.collectionEmpty"))
        } else {
            LazyVGrid(columns: Self.columns, spacing: 8) {
                ForEach(viewModel.cells) { cell in
                    NftGridCell(model: cell, onLike: {}, onCart: {})
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct PreviewNftService: NftService {
    func loadNft(id: String) async throws -> Nft {
        let image: URL? = URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")
        return Nft(id: id, name: "April", images: [image].compactMap { $0 }, rating: 3, price: 1.78, author: "John Doe")
    }
}

#Preview {
    let collection = NftCollection(
        id: "1",
        name: "Peach",
        cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
        nfts: ["1", "2", "3", "4", "5"],
        description: "Sample NFT collection",
        author: "John Doe",
        website: "https://fakenfts.org/"
    )
    CollectionView(collection: collection, nftService: PreviewNftService())
}
