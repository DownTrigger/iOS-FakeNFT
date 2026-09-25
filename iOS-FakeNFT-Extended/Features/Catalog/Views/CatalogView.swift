import SwiftUI

struct CatalogView: View {
    @State private var viewModel: CatalogViewModel
    @State private var isSortSheetPresented = false

    init(service: CollectionsService) {
        _viewModel = State(initialValue: CatalogViewModel(service: service))
    }

    var body: some View {
        List {
            ForEach(viewModel.collections) { collection in
                CollectionCell(collection: collection)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 17, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.fnBackground))
                    .task { await viewModel.loadNextPageIfNeeded(currentItem: collection) }
            }

            if viewModel.isLoadingNextPage {
                ProgressView()
                    .tint(Color(.fnText))
                    .frame(maxWidth: .infinity)
                    .id(viewModel.collections.count)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(.fnBackground))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.fnBackground))
        .overlay {
            if viewModel.isInitialLoading {
                AppLoadingView()
            }
        }
        .task { await viewModel.loadNextPage() }
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
            Task { await viewModel.selectSort(option) }
        }
    }
}

private struct PreviewCollectionsService: CollectionsService {
    func loadCollections(page: Int, size: Int, sortBy: String?) async throws -> [NftCollection] {
        let names = ["Peach", "Blue", "Brown", "Beige", "Pink", "Grey", "White", "Yellow", "Green", "Orange"]
        let start = page * size
        guard start < names.count else { return [] }
        return names[start..<min(start + size, names.count)].enumerated().map { offset, name in
            NftCollection(
                id: String(start + offset),
                name: name,
                cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/\(name).png"),
                nfts: (1...(offset + 3)).map(String.init)
            )
        }
    }
}

#Preview {
    NavigationStack {
        CatalogView(service: PreviewCollectionsService())
    }
}
