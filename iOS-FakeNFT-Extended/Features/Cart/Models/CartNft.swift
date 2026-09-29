import Foundation

struct CartNft: Decodable, Identifiable, Sendable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Double

    var imageURL: URL? {
        images.first
    }
}
