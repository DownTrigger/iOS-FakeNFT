import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private static let pageSize = 5

    private(set) var sortOption: CatalogSortOption = .byNftCount
    private(set) var hasLoadError = false
    var alert: AlertModel?

    private let service: CollectionsService
    private var paginator: Paginator<NftCollection>?
    private var paginatorSortBy: String?
    private var isLoadingAllPages = false

    var collections: [NftCollection] {
        switch sortOption {
        case .byTitle:
            paginator?.items ?? []
        case .byNftCount:
            isLoadingAllPages ? [] : (paginator?.items ?? []).sorted { $0.nftCount > $1.nftCount }
        }
    }

    var isInitialLoading: Bool {
        isLoadingAllPages || (paginator?.isLoading == true && paginator?.items.isEmpty == true)
    }
    var isLoadingNextPage: Bool {
        !isLoadingAllPages && paginator?.isLoading == true && paginator?.items.isEmpty == false
    }
    var isEmpty: Bool {
        guard let paginator else { return false }
        return !paginator.isLoading && paginator.items.isEmpty && !paginator.hasMorePages
    }

    private var loadsAllPages: Bool { sortOption.serverSortBy == nil }

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
        let needsMorePages = loadsAllPages && paginator?.hasMorePages == true
        guard paginator?.items.isEmpty == true || needsMorePages else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard let paginator else { return }
        hasLoadError = false
        do {
            if loadsAllPages {
                isLoadingAllPages = true
                defer { isLoadingAllPages = false }
                try await paginator.loadAllPages()
            } else {
                try await paginator.loadNextPage()
            }
        } catch {
            guard !error.isCancellation else { return }
            hasLoadError = paginator.items.isEmpty
            alert = .retryError(title: CatalogLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.loadNextPage() }
            }
        }
    }

    func refresh() async {
        let freshPaginator = Self.makePaginator(service: service, sortBy: paginatorSortBy)
        do {
            let currentItems: [NftCollection]?
            if loadsAllPages {
                try await freshPaginator.loadAllPages()
                currentItems = paginator?.items
            } else {
                try await freshPaginator.loadNextPage()
                currentItems = paginator.map { Array($0.items.prefix(freshPaginator.items.count)) }
            }
            guard freshPaginator.items != currentItems else { return }
            paginator = freshPaginator
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: CatalogLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.refresh() }
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
