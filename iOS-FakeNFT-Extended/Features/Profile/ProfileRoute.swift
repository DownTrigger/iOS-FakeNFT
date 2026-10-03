import Foundation

enum ProfileRoute: Hashable {
    case myNFTs(nftIds: [String], likedIds: [String], username: String)
    case editProfile(user: UserModel)
    case website(url: URL)
}
