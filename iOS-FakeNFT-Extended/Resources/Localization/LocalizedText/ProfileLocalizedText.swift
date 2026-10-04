import SwiftUI

enum ProfileLocalizedText {
    case myNFTsEmpty
    case myNFTsLoadError
    case profileLoadError
    case favouriteNFTsEmpty
    case favouriteNFTsLoadError

    var key: LocalizedStringKey {
        switch self {
        case .myNFTsEmpty:           "profile.myNFTs.empty"
        case .myNFTsLoadError:       "profile.myNFTs.loadError"
        case .profileLoadError:      "profile.loadError"
        case .favouriteNFTsEmpty:    "profile.favouriteNFTs.empty"
        case .favouriteNFTsLoadError: "profile.favouriteNFTs.loadError"
        }
    }
}
