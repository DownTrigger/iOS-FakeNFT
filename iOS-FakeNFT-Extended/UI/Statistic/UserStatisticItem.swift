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
