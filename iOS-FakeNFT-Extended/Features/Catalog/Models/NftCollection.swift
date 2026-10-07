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

extension NftCollection {
    private enum CodingKeys: String, CodingKey {
        case id, name, cover, nfts, description, author, website
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var seen = Set<String>()
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        cover = try container.decodeIfPresent(URL.self, forKey: .cover)
        nfts = try container.decode([String].self, forKey: .nfts).filter { seen.insert($0).inserted }
        description = try container.decode(String.self, forKey: .description)
        author = try container.decode(String.self, forKey: .author)
        website = try container.decode(String.self, forKey: .website)
    }
}
