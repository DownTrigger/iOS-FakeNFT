import Foundation

struct PaymentResult: Decodable, Sendable {
    let success: Bool
    let orderId: String
    let id: String
}
