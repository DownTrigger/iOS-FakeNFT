import Foundation

@MainActor
@Observable
final class StatisticsViewModel {
    private static let pageSize = 25

    private(set) var sortOption: StatisticsSortOption = .byRating
    private(set) var hasLoadError = false
    var alert: AlertModel?

    private let userService: UserServiceProtocol
    private var paginator: Paginator<UserResponse>?
    private var paginatorSortBy: String?
    private var isLoadingAllPages = false

    var statistics: [UserStatisticItem] {
        let users: [UserResponse]
        switch sortOption {
        case .byName:
            users = paginator?.items ?? []
        case .byRating:
            users = isLoadingAllPages ? [] : (paginator?.items ?? []).sorted { $0.nfts.count > $1.nfts.count }
        }
        return users.enumerated().map { index, user in
            UserStatisticItem(position: index + 1, response: user)
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

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func applySort(_ option: StatisticsSortOption) async {
        sortOption = option
        let sortBy = option.serverSortBy
        if paginator == nil || (sortBy != nil && sortBy != paginatorSortBy) {
            paginatorSortBy = sortBy
            paginator = Self.makePaginator(service: userService, sortBy: sortBy)
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
            alert = .retryError(title: StatisticLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.loadNextPage() }
            }
        }
    }

    func loadNextPageIfNeeded(currentItem: UserStatisticItem) async {
        guard currentItem.id == statistics.last?.id else { return }
        await loadNextPage()
    }

    func refresh() async {
        let freshPaginator = Self.makePaginator(service: userService, sortBy: paginatorSortBy)
        do {
            if loadsAllPages {
                try await freshPaginator.loadAllPages()
            } else {
                try await freshPaginator.loadNextPage()
            }
            paginator = freshPaginator
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: StatisticLocalizedText.refreshError.resource) { [weak self] in
                Task { await self?.refresh() }
            }
        }
    }

    private static func makePaginator(service: UserServiceProtocol, sortBy: String?) -> Paginator<UserResponse> {
        Paginator(pageSize: pageSize) { page, size in
            try await service.loadUsers(page: page, size: size, sortBy: sortBy)
        }
    }
}

private extension StatisticsSortOption {
    var serverSortBy: String? {
        switch self {
        case .byName:
            "name,asc"
        case .byRating:
            nil
        }
    }
}
