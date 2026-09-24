import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private(set) var sortOption: CatalogSortOption = .byNftCount

    private let paginator: Paginator<NftCollection>

    var collections: [NftCollection] { paginator.items }

    init(service: CollectionsService) {
        paginator = Paginator(pageSize: 10) { page, size in
            try await service.loadCollections(page: page, size: size)
        }
    }

    func selectSort(_ option: CatalogSortOption) {
        sortOption = option
    }

    func loadNextPage() async {
        try? await paginator.loadNextPage()
    }

    func loadNextPageIfNeeded(currentItem: NftCollection) async {
        try? await paginator.loadNextPageIfNeeded(currentItem: currentItem)
    }
}
