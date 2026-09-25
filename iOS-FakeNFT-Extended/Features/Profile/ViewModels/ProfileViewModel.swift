//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//

import Observation

@Observable
final class ProfileViewModel {

    // Data
    var user: UserModel = UserModel(
        avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIMUe7M2kZo-Yb2FPmD6bbleK3Ri3tQNR0Gtp8aFiQ2UAF5VHukRALrltv&s=10",
        username: "Joaquin Phoenix",
        bio: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT.",
        userWebSite: "https://example.com",
        nftCount: 123,
        favouritesCount: 11
    )

    // Actions for buttons
    func openEditProfile() {
        // TODO: nav to edit profile
    }

    func openMyNFTs() {
        // TODO: nav to nft list
    }

    func openFavouriteNFTs() {
        // TODO: nav to nft list
    }
}
