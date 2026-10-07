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
    var statistics: [UserStatisticItem] = []
    var alert: AlertModel?

    private let userService: UserServiceProtocol

    private var isLoaded = false
    var isLoading = false

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    // MARK: - Preview init
    fileprivate init(statistics: [UserStatisticItem]) {
        self.statistics = statistics
        self.userService = PreviewUserService()
        self.isLoaded = true
    }

    func loadStatistics() async {
        guard !isLoaded, !isLoading else { return }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let users = try await userService.loadUsers()
            statistics = makeStatistics(from: users)
            isLoaded = true
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(
                title: StatisticLocalizedText.loadError.resource,
                onRetry: { [weak self] in
                    Task {
                        await self?.loadStatistics()
                    }
                }
            )
        }
    }

    func refreshStatistics() async {
        guard !isLoading else { return }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let users = try await userService.loadUsers()
            statistics = makeStatistics(from: users)
            isLoaded = true
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(
                title: StatisticLocalizedText.refreshError.resource,
                onRetry: { [weak self] in
                    Task {
                        await self?.refreshStatistics()
                    }
                }
            )
        }
    }

    func sortStatisticsByName(ascending: Bool = true) {
        statistics = sortBy(
            statistics,
            keyPath: \.user.username,
            ascending: ascending
        )
    }

    func sortStatisticsByRating(ascending: Bool = false) {
        statistics = sortBy(
            statistics,
            keyPath: \.nfts.count,
            ascending: ascending
        )
    }

    func resetCache() {
        statistics = []
        isLoaded = false
    }

    private func makeStatistics(from users: [UserResponse]) -> [UserStatisticItem] {
        users
            .map { user in
                UserStatisticItem(
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
                    position: index + 1,
                    user: statistic.user,
                    nfts: statistic.nfts
                )
            }
    }
}

// MARK: mock - данные
extension StatisticsViewModel {
    static var preview: StatisticsViewModel {
        let viewModel = StatisticsViewModel(
            userService: PreviewUserService()
        )

        return viewModel
    }
}
