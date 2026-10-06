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

    var resource: LocalizedStringResource {
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
}
