//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import Observation

@Observable
final class StatisticsViewModel {
    var statistics: [UserStatisticItem] = []

    private let userService: UserServiceProtocol

    private var isLoaded = false

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
        guard !isLoaded else {
            return
        }

        do {
            let users = try await userService.loadUsers()

            let statistics = users
                .map { user in
                    UserStatisticItem(
                        position: 0,
                        user: UserModel(
                            avatar: user.avatar,
                            username: user.name,
                            bio: user.description ?? "",
                            userWebSite: user.website
                        ),
                        countNft: user.nfts.count
                    )
                }
                .sorted {
                    $0.countNft > $1.countNft
                }
                .enumerated()
                .map { index, statistic in
                    UserStatisticItem(
                        position: index + 1,
                        user: statistic.user,
                        countNft: statistic.countNft
                    )
                }

            self.statistics = statistics
            self.isLoaded = true
        } catch {
            print("Failed to load statistics: \(error)")
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
            keyPath: \.countNft,
            ascending: ascending
        )
    }

    func resetCache() {
        statistics = []
        isLoaded = false
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
