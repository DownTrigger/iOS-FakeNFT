import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let images: [URL]
    let raiting: Int
    let price: Double
    let description: String
}
