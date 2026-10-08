import Foundation

enum AlertLocalizedText {
    case retry
    case cancel
    case ok

    var resource: LocalizedStringResource {
        switch self {
        case .retry:
            "Error.repeat"
        case .cancel:
            "Alert.cancel"
        case .ok:
            "Alert.ok"
        }
    }
}
