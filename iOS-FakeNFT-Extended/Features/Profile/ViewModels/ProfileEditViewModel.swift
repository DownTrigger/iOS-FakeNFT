//
//  ProfileEditViewModel.swift
//  iOS-FakeNFT-Extended
//

import Observation

@Observable
final class ProfileEditViewModel {
    var name: String
    var bio: String
    var website: String
    var avatarURL: String

    private let original: UserModel

    init(user: UserModel) {
        self.original = user
        self.name = user.username
        self.bio = user.bio
        self.website = user.userWebSite ?? ""
        self.avatarURL = user.avatar ?? ""
    }

    var hasChanges: Bool {
        name != original.username ||
        bio != original.bio ||
        website != (original.userWebSite ?? "") ||
        avatarURL != (original.avatar ?? "")
    }

    func buildUpdatedUser() -> UserModel {
        UserModel(
            avatar: avatarURL.isEmpty ? nil : avatarURL,
            username: name,
            bio: bio,
            userWebSite: website.isEmpty ? nil : website,
            nftCount: original.nftCount,
            favouritesCount: original.favouritesCount
        )
    }
}
