import Foundation

struct Currency: Decodable, Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let name: String
    let imageURL: URL?

    var displayTitle: String {
        title.replacingOccurrences(of: "_", with: " ")
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case imageURL = "image"
    }
}
