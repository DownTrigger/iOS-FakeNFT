//
//  UserModel.swift
//  iOS-FakeNFT-Extended
//

struct UserModel: Sendable, Hashable {
    let avatar: String?
    let username: String
    let bio: String
    let userWebSite: String?
    let nfts: [String]
    let likes: [String]

    var nftCount: Int { nfts.count }
}

extension UserModel {
    init(profile: UserProfile) {
        self.init(
            avatar: profile.avatar,
            username: profile.name,
            bio: profile.description,
            userWebSite: profile.website,
            nfts: profile.nfts,
            likes: profile.likes
        )
    }
}
