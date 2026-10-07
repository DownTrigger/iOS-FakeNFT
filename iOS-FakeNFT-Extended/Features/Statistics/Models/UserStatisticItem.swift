//
//  UserStatisticItem.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import Foundation

struct UserStatisticItem: Identifiable, Hashable {
    let id: String
    let position: Int
    let user: UserModel
    let nfts: [String]
}

extension UserStatisticItem {
    init(position: Int, response user: UserResponse) {
        self.init(
            id: user.id,
            position: position,
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
}
