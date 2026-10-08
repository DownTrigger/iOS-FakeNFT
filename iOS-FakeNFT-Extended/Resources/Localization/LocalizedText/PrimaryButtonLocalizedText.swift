import SwiftUI

enum PrimaryButtonLocalizedText {
    case pay
    case save

    var key: LocalizedStringKey {
        switch self {
        case .pay:
            "button.pay"
        case .save:
            "button.save"
        }
    }
}
