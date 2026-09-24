//
//  StatisticsViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import Observation

@Observable
final class StatisticsViewModel {
    
    // mock данные заменить на реальный код
    var statistics: [UserStatisticItem] = []
    
    init() {
        //        self.statistics = []
        //        loadStatistics()
        self.statistics = Self.preview.statistics
    }
    
    fileprivate init(statistics: [UserStatisticItem]) {
        self.statistics = statistics
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
}

// mock - данные
extension StatisticsViewModel {
    static var preview: StatisticsViewModel {
        
        let users: [UserModel] = [
            UserModel(
                avatar: "imgAvatarPlaceholder",
                username: "Alex",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: nil,
                username: "Igor",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: nil,
                username: "Natasha",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: "imgAvatarPlaceholder",
                username: "Petr",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: "imgAvatarPlaceholder",
                username: "Timothey",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: "imgAvatarPlaceholder",
                username: "Olya",
                bio: "",
                userWebSite: nil
            ),
            UserModel(
                avatar: "imgAvatarPlaceholder",
                username: "Zoya",
                bio: "",
                userWebSite: nil
            )
        ]
        
        let nftCounts = [
            ("Zoya", 112),
            ("Petr", 98),
            ("Igor", 72),
            ("Natasha", 71),
            ("Timothey", 51),
            ("Alex", 23),
            ("Olya", 11)
        ]
        
        let statistics = users
            .compactMap { user -> UserStatisticItem? in
                guard let countNft = nftCounts.first(
                    where: { $0.0 == user.username }
                )?.1 else {
                    return nil
                }
                
                return UserStatisticItem(
                    position: 0,
                    user: user,
                    countNft: countNft
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
        
        return StatisticsViewModel(
            statistics: statistics
        )
    }
}
