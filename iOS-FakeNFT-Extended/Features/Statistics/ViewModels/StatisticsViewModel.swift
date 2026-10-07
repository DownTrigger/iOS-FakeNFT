//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

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

    var statistics: [UserStatisticItem] {
        (paginator?.items ?? []).enumerated().map { index, user in
            UserStatisticItem(position: index + 1, response: user)
        }
    }

    var isInitialLoading: Bool {
        paginator?.isLoading == true && paginator?.items.isEmpty == true
    }
    var isLoadingNextPage: Bool {
        paginator?.isLoading == true && paginator?.items.isEmpty == false
    }
    var isEmpty: Bool {
        guard let paginator else { return false }
        return !paginator.isLoading && paginator.items.isEmpty && !paginator.hasMorePages
    }

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func applySort(_ option: StatisticsSortOption) async {
        let previousSortBy = sortOption.serverSortBy
        sortOption = option
        if paginator == nil || option.serverSortBy != previousSortBy {
            paginator = Self.makePaginator(service: userService, sortBy: option.serverSortBy)
        }
        guard paginator?.items.isEmpty == true else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard let paginator else { return }
        hasLoadError = false
        do {
            try await paginator.loadNextPage()
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
        let freshPaginator = Self.makePaginator(service: userService, sortBy: sortOption.serverSortBy)
        do {
            try await freshPaginator.loadNextPage()
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
    var serverSortBy: String {
        switch self {
        case .byName:
            "name,asc"
        case .byRating:
            "rating,desc"
        }
    }
}
