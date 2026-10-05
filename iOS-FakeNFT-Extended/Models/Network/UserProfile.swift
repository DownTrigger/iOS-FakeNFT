import Foundation

struct UserProfile: Decodable, Sendable, Equatable {
    let id: String
    let name: String
    let description: String
    let website: String?
    let avatar: String?
    let nfts: [String]
    let likes: [String]
}
