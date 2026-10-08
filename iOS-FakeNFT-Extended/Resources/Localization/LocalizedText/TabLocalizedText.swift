import SwiftUI

enum TabLocalizedText {
    case profile
    case catalog
    case cart
    case statistics

    var key: LocalizedStringKey {
        switch self {
        case .profile:
            "Tab.profile"
        case .catalog:
            "Tab.catalog"
        case .cart:
            "Tab.cart"
        case .statistics:
            "Tab.statistics"
        }
    }
}
