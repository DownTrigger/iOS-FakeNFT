import SwiftUI

enum ScreenLocalizedText {
    case sorting
    case profilePhoto
    case myNFTs
    case favouriteNFTs

    var key: LocalizedStringKey {
        switch self {
        case .sorting:
            "sorting.sorting"
        case .profilePhoto:
            "sorting.profilePhoto"
        case .myNFTs:
            "profile.myNFTs"
        case .favouriteNFTs:
            "profile.favouriteNFTs"
        }
    }
}
