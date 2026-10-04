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
    case deleteError
    case paymentTitle
    case agreementText
    case agreementLink
    case currenciesLoadError
    case paymentError
    case paymentSuccess
    case backToCart

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
        case .deleteError:
            "cart.deleteError"
        case .paymentTitle:
            "cart.paymentTitle"
        case .agreementText:
            "cart.agreementText"
        case .agreementLink:
            "cart.agreementLink"
        case .currenciesLoadError:
            "cart.currenciesLoadError"
        case .paymentError:
            "cart.paymentError"
        case .paymentSuccess:
            "cart.paymentSuccess"
        case .backToCart:
            "cart.backToCart"
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
        case .deleteError:
            String(localized: "cart.deleteError")
        case .paymentTitle:
            String(localized: "cart.paymentTitle")
        case .agreementText:
            String(localized: "cart.agreementText")
        case .agreementLink:
            String(localized: "cart.agreementLink")
        case .currenciesLoadError:
            String(localized: "cart.currenciesLoadError")
        case .paymentError:
            String(localized: "cart.paymentError")
        case .paymentSuccess:
            String(localized: "cart.paymentSuccess")
        case .backToCart:
            String(localized: "cart.backToCart")
        }
    }
}
