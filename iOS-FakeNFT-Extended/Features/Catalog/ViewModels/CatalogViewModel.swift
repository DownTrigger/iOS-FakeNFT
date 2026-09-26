import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private static let pageSize = 5

    private(set) var sortOption: CatalogSortOption = .byNftCount
    var alert: AlertModel?

    private let service: CollectionsService
    private var paginator: Paginator<NftCollection>?
    private var paginatorSortBy: String?

    var collections: [NftCollection] {
        switch sortOption {
        case .byTitle:
            paginator?.items ?? []
        case .byNftCount:
            (paginator?.items ?? []).sorted { $0.nftCount > $1.nftCount }
        }
    }

    var isInitialLoading: Bool { paginator?.isLoading == true && paginator?.items.isEmpty == true }
    var isLoadingNextPage: Bool { paginator?.isLoading == true && paginator?.items.isEmpty == false }
    var isEmpty: Bool {
        guard let paginator else { return false }
        return !paginator.isLoading && paginator.items.isEmpty && !paginator.hasMorePages
    }

    init(service: CollectionsService) {
        self.service = service
    }

    func applySort(_ option: CatalogSortOption) async {
        sortOption = option
        let sortBy = option.serverSortBy
        if paginator == nil || (sortBy != nil && sortBy != paginatorSortBy) {
            paginatorSortBy = sortBy
            paginator = Self.makePaginator(service: service, sortBy: sortBy)
        }
        guard paginator?.items.isEmpty == true else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard let paginator else { return }
        do {
            try await paginator.loadNextPage()
        } catch {
            guard !Self.isCancellation(error) else { return }
            alert = .retryError(title: String(localized: "Error.loadData")) { [weak self] in
                Task { await self?.loadNextPage() }
            }
        }
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

    private static func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
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
