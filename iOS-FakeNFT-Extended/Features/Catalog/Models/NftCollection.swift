import Foundation

struct NftCollection: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let cover: URL?
    let nfts: [String]
    let description: String
    let author: String
    let website: String

    var nftCount: Int { nfts.count }
    var websiteURL: URL? { URL(string: website) }
}
