import Foundation

enum ProfileRoute: Hashable {
    case myNFTs(user: UserModel)
    case favouriteNFTs
    case editProfile(user: UserModel)
    case website(url: URL)
}
