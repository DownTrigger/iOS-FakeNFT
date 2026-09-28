import Foundation

struct Order: Decodable, Sendable {
    let id: String
    let nfts: [String]
}
