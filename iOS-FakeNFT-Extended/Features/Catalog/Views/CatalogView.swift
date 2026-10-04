import SwiftUI

struct CatalogView: View {
    private static let sortOptionKey = "catalog.sortOption"

    @Environment(Router<CatalogRoute>.self) private var router
    @State private var viewModel: CatalogViewModel
    @State private var isSortSheetPresented = false
    @AppStorage(Self.sortOptionKey) private var sortOption: CatalogSortOption = .byNftCount

    init(service: CollectionsService) {
        _viewModel = State(initialValue: CatalogViewModel(service: service))
    }

    var body: some View {
        List {
            ForEach(viewModel.collections) { collection in
                Button {
                    router.push(.collection(collection))
                } label: {
                    CollectionCell(collection: collection)
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 17, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color(.fnBackground))
                .task { await viewModel.loadNextPageIfNeeded(currentItem: collection) }
            }
        }
        .listStyle(.plain)
        .refreshable { await viewModel.refresh() }
        .scrollContentBackground(.hidden)
        .background(Color(.fnBackground))
        .safeAreaInset(edge: .bottom) {
            if viewModel.isLoadingNextPage {
                ProgressView()
                    .tint(Color(.fnText))
                    .padding(.vertical, 8)
            }
        }
        .overlay {
            if viewModel.isInitialLoading {
                AppLoadingView()
            } else if viewModel.isEmpty {
                EmptyStateView(message: CatalogLocalizedText.empty.text)
            }
        }
        .task(id: sortOption) { await viewModel.applySort(sortOption) }
        .appAlert(item: $viewModel.alert)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationSortButton {
                    isSortSheetPresented = true
                }
            }
        }
        .sortSheet(
            isPresented: $isSortSheetPresented,
            options: [CatalogSortOption.byTitle, .byNftCount]
        ) { option in
            sortOption = option
        }
    }
}

private struct PreviewCollectionsService: CollectionsService {
    private static let names: [String] = ["Peach", "Blue", "Brown", "Beige", "Pink", "Grey", "White", "Yellow"]

    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection] {
        let start: Int = page * size
        guard start < Self.names.count else { return [] }
        let end: Int = min(start + size, Self.names.count)
        return (start..<end).map { Self.makeCollection(index: $0) }
    }

    private static func makeCollection(index: Int) -> NftCollection {
        let name: String = names[index]
        let cover: URL? = URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/\(name).png")
        let nfts: [String] = (0..<(index % 3 + 3)).map { String($0) }
        return NftCollection(
            id: String(index),
            name: name,
            cover: cover,
            nfts: nfts,
            description: "Sample NFT collection",
            author: "Lourdes Harper",
            website: "https://lourdes_harper.fakenfts.org/"
        )
    }
}

#Preview {
    NavigationStack {
        CatalogView(service: PreviewCollectionsService())
    }
    .environment(Router<CatalogRoute>())
}
