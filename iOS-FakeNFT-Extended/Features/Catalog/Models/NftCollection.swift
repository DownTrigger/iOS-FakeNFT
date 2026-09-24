import Foundation

struct NftCollection: Identifiable, Sendable {
    let id: String
    let name: String
    let cover: URL?
    let nftCount: Int
}
