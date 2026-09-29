import SwiftUI

enum CartLocalizedText {
    case price
    case empty
    case toPayment
    case loadError
    case nftCount(Int)
    case deleteConfirmation
    case delete
    case back

    var key: LocalizedStringKey {
        switch self {
        case .price:
            "cart.price"
        case .empty:
            "cart.empty"
        case .toPayment:
            "cart.toPayment"
        case .loadError:
            "cart.loadError"
        case .nftCount(let count):
            "cart.nftCount \(count)"
        case .deleteConfirmation:
            "cart.deleteConfirmation"
        case .delete:
            "cart.delete"
        case .back:
            "cart.back"
        }
    }

    var text: String {
        switch self {
        case .price:
            String(localized: "cart.price")
        case .empty:
            String(localized: "cart.empty")
        case .toPayment:
            String(localized: "cart.toPayment")
        case .loadError:
            String(localized: "cart.loadError")
        case .nftCount(let count):
            String(localized: "cart.nftCount \(count)")
        case .deleteConfirmation:
            String(localized: "cart.deleteConfirmation")
        case .delete:
            String(localized: "cart.delete")
        case .back:
            String(localized: "cart.back")
        }
    }
}
