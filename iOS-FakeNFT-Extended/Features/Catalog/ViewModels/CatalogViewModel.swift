import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private static let sortOptionKey = "catalog.sortOption"
    private static let pageSize = 10

    private(set) var sortOption: CatalogSortOption

    private let service: CollectionsService
    private let defaults: UserDefaults
    private var paginator: Paginator<NftCollection>
    private var paginatorSortBy: String?

    var collections: [NftCollection] {
        switch sortOption {
        case .byTitle:
            paginator.items
        case .byNftCount:
            paginator.items.sorted { $0.nftCount > $1.nftCount }
        }
    }

    init(service: CollectionsService, defaults: UserDefaults = .standard) {
        let savedOption = defaults.string(forKey: Self.sortOptionKey).flatMap(CatalogSortOption.init(rawValue:))
        let sortOption = savedOption ?? .byNftCount

        self.service = service
        self.defaults = defaults
        self.sortOption = sortOption
        self.paginatorSortBy = sortOption.serverSortBy
        self.paginator = Self.makePaginator(service: service, sortBy: sortOption.serverSortBy)
    }

    func selectSort(_ option: CatalogSortOption) async {
        guard option != sortOption else { return }
        sortOption = option
        defaults.set(option.rawValue, forKey: Self.sortOptionKey)

        guard let sortBy = option.serverSortBy, sortBy != paginatorSortBy else { return }
        paginatorSortBy = sortBy
        paginator = Self.makePaginator(service: service, sortBy: sortBy)
        await loadNextPage()
    }

    func loadNextPage() async {
        try? await paginator.loadNextPage()
    }

    func loadNextPageIfNeeded(currentItem: NftCollection) async {
        guard currentItem.id == collections.last?.id else { return }
        await loadNextPage()
    }

    private static func makePaginator(service: CollectionsService, sortBy: String?) -> Paginator<NftCollection> {
        Paginator(pageSize: pageSize) { page, size in
            try await service.loadCollections(page: page, size: size, sortBy: sortBy)
        }
    }
}

private extension CatalogSortOption {
    var serverSortBy: String? {
        switch self {
        case .byTitle:
            "name,asc"
        case .byNftCount:
            nil
        }
    }
}
