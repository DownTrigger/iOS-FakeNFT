//
//  UserModel.swift
//  iOS-FakeNFT-Extended
//

struct UserModel: Sendable, Hashable {
    let avatar: String?
    let username: String
    let bio: String
    let userWebSite: String?
    let nftCount: Int
    let favouritesCount: Int
}
