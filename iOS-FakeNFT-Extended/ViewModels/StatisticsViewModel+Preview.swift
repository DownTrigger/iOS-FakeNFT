//
//  StatisticsViewModel+Preview.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct PreviewUserService: UserServiceProtocol {
    func loadUsers() async throws -> [UserResponse] {
        [
            UserResponse(
                name: "Alex",
                avatar: "https://i.pravatar.cc/150?img=12",
                description: "Дизайнер из Казани, люблю цифровое искусство и бейглы. " +
                "В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
                website: "https://www.apple.com",
                nfts: Array(repeating: "nft", count: 23)
            ),
            UserResponse(
                name: "Igor",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 72)
            ),
            UserResponse(
                name: "Natasha",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 71)
            ),
            UserResponse(
                name: "Petr",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 98)
            ),
            UserResponse(
                name: "Timothey",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 51)
            ),
            UserResponse(
                name: "Olya",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 11)
            ),
            UserResponse(
                name: "Zoya",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: Array(repeating: "nft", count: 112)
            )
        ]
    }
}
