import Foundation

struct UserOrder: Decodable, Sendable, Equatable {
    let id: String
    let nfts: [String]
}
