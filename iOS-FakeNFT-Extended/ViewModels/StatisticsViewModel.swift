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
    private(set) var state: LoadingState<[UserStatisticItem]> = .idle
    private(set) var sortOption: StatisticsSortOption = .byRating
    var alert: AlertModel?

    private let userService: UserServiceProtocol

    var statistics: [UserStatisticItem] {
        guard case let .loaded(items) = state else { return [] }
        switch sortOption {
        case .byName:
            return sortBy(items, keyPath: \.user.username, ascending: true)
        case .byRating:
            return sortBy(items, keyPath: \.nfts.count, ascending: false)
        }
    }

    var isLoading: Bool { state.isLoading }

    var isEmpty: Bool {
        guard case let .loaded(items) = state else { return false }
        return items.isEmpty
    }

    var isFailed: Bool {
        guard case .failed = state else { return false }
        return true
    }

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    fileprivate init(statistics: [UserStatisticItem]) {
        self.state = .loaded(statistics)
        self.userService = PreviewUserService()
    }

    func applySort(_ option: StatisticsSortOption) {
        sortOption = option
    }

    func load() async {
        guard state.canStartLoading else { return }
        state = .loading
        do {
            state = .loaded(try await fetchStatistics())
        } catch {
            guard !error.isCancellation else {
                state = .idle
                return
            }
            state = .failed(error)
            alert = .retryError(title: StatisticLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.load() }
            }
        }
    }

    func refresh() async {
        guard case .loaded = state else {
            await load()
            return
        }
        do {
            state = .loaded(try await fetchStatistics())
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: StatisticLocalizedText.refreshError.resource) { [weak self] in
                Task { await self?.refresh() }
            }
        }
    }

    private func fetchStatistics() async throws -> [UserStatisticItem] {
        let users = try await userService.loadUsers()
        return Self.makeStatistics(from: users)
    }

    private static func makeStatistics(from users: [UserResponse]) -> [UserStatisticItem] {
        users
            .map { user in
                UserStatisticItem(
                    id: user.id,
                    position: 0,
                    user: UserModel(
                        avatar: user.avatar,
                        username: user.name,
                        bio: user.description ?? "",
                        userWebSite: user.website,
                        nfts: user.nfts,
                        likes: []
                    ),
                    nfts: user.nfts
                )
            }
            .sorted {
                $0.nfts.count > $1.nfts.count
            }
            .enumerated()
            .map { index, statistic in
                UserStatisticItem(
                    id: statistic.id,
                    position: index + 1,
                    user: statistic.user,
                    nfts: statistic.nfts
                )
            }
    }
}

extension StatisticsViewModel {
    static var preview: StatisticsViewModel {
        StatisticsViewModel(
            statistics: makeStatistics(from: PreviewUserService.users)
        )
    }
}
