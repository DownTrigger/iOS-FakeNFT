import Foundation

struct NftCollection: Decodable, Identifiable, Sendable {
    let id: String
    let name: String
    let cover: URL?
    let nfts: [String]

    var nftCount: Int { nfts.count }
}
