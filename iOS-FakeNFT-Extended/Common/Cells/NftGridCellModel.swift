import Foundation

struct NftGridCellModel: Identifiable, Sendable {
    let id: String
    let imageURL: URL?
    let name: String
    let rating: Int
    let priceText: String
    let isLiked: Bool
    let isInCart: Bool
}
