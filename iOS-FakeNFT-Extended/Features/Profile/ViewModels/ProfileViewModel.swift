//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    var user: UserModel = UserModel(
        avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIMUe7M2kZo-Yb2FPmD6bbleK3Ri3tQNR0Gtp8aFiQ2UAF5VHukRALrltv&s=10",
        username: "Joaquin Phoenix",
        bio: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT.",
        userWebSite: "https://example.com",
        nftCount: 123,
        favouritesCount: 11
    )

    var websiteURL: URL? {
        guard let website = user.userWebSite, !website.isEmpty else { return nil }
        return URL(string: website)
    }

    func updateUser(_ user: UserModel) {
        self.user = user
    }

    func openMyNFTs() {
        // TODO: nav to nft list
    }

    func openFavouriteNFTs() {
        // TODO: nav to nft list
    }
}
