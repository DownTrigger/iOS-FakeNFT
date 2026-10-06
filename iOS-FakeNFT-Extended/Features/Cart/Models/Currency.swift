import Foundation

struct Currency: Decodable, Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let name: String
    let image: URL?

    var displayTitle: String {
        title.replacingOccurrences(of: "_", with: " ")
    }
}
