import SwiftUI

struct CollectionView: View {
    private static let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 9), count: 3)

    @Environment(Router<CatalogRoute>.self) private var router
    @State private var viewModel: CollectionViewModel
    @State private var selectedCell: NftGridCellModel?

    init(
        collection: NftCollection,
        collectionsService: CollectionsService,
        nftService: NftService,
        userState: UserState
    ) {
        _viewModel = State(initialValue: CollectionViewModel(
            collection: collection,
            collectionsService: collectionsService,
            nftService: nftService,
            userState: userState
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CollectionHeaderView(collection: viewModel.collection, onAuthorTap: openAuthorWebsite)
                nfts
            }
            .padding(.bottom, 16)
        }
        .refreshable { await viewModel.refresh() }
        .ignoresSafeArea(edges: .top)
        .hiddenTopScrollEdgeEffect()
        .background(Color(.fnBackground))
        .toolbar(.hidden, for: .tabBar)
        .backButton { router.pop() }
        .task { await viewModel.loadNfts() }
        .appAlert(item: $viewModel.alert)
        .sheet(item: $selectedCell) { cell in
            NftDetailView(nftId: cell.id)
        }
    }

    private func openAuthorWebsite() {
        guard let url = viewModel.collection.websiteURL else { return }
        router.push(.website(url))
    }

    @ViewBuilder
    private var nfts: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(Color(.fnText))
                .frame(maxWidth: .infinity)
        } else if viewModel.isEmpty {
            EmptyStateView(message: CatalogLocalizedText.collectionEmpty.key)
        } else if viewModel.isFailed && viewModel.alert == nil {
            ErrorStateView(message: CatalogLocalizedText.loadError.key) {
                Task { await viewModel.loadNfts() }
            }
        } else {
            LazyVGrid(columns: Self.columns, spacing: 8) {
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
        }
    }
}

private extension View {
    @ViewBuilder
    func hiddenTopScrollEdgeEffect() -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectHidden(true, for: .top)
        } else {
            self
        }
    }
}

private struct PreviewCollectionsService: CollectionsService {
    let collection: NftCollection

    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection] {
        []
    }

    func loadCollection(id: String) async throws -> NftCollection {
        collection
    }
}

private struct PreviewNftService: NftService {
    func loadNft(id: String) async throws -> Nft {
        let image: URL? = URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")
        return Nft(
            id: id,
            name: "April",
            images: [image].compactMap { $0 },
            description: "",
            rating: 3,
            price: 1.78,
            author: "John Doe"
        )
    }
}

private struct PreviewUserProfileService: UserProfileService {
    func loadProfile() async throws -> UserProfile {
        UserProfile(id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [], likes: ["1", "3"])
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        try await loadProfile()
    }

    func updateProfile(
        name: String,
        description: String,
        avatar: String?,
        website: String?
    ) async throws -> UserProfile {
        try await loadProfile()
    }
}

private struct PreviewUserOrderService: UserOrderService {
    func loadOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: ["2"])
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        try await loadOrder()
    }

    func clearOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: [])
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
    NavigationStack {
        CollectionView(
            collection: collection,
            collectionsService: PreviewCollectionsService(collection: collection),
            nftService: PreviewNftService(),
            userState: UserState(profileService: PreviewUserProfileService(), orderService: PreviewUserOrderService())
        )
    }
    .environment(Router<CatalogRoute>())
}
