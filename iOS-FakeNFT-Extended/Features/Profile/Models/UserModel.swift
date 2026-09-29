//
//  UserModel.swift
//  iOS-FakeNFT-Extended
//

struct UserModel: Decodable, Sendable, Hashable {
    let avatar: String?
    let username: String
    let bio: String
    let userWebSite: String?
    let nfts: [String]
    let likes: [String]
    
    var nftCount: Int { nfts.count }
    var favouritesCount: Int { likes.count }
    
    enum CodingKeys: String, CodingKey {
        case avatar
        case username = "name"
        case bio = "description"
        case userWebSite = "website"
        case nfts
        case likes
    }
}
