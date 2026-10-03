import SwiftUI

enum ProfileLocalizedText {
    case myNFTsEmpty
    case myNFTsLoadError
    case profileLoadError

    var key: LocalizedStringKey {
        switch self {
        case .myNFTsEmpty:      "profile.myNFTs.empty"
        case .myNFTsLoadError:  "profile.myNFTs.loadError"
        case .profileLoadError: "profile.loadError"
        }
    }
}
