//
//  ProfileViewModel.swift
//  iOS-FakeNFT-Extended
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {

    var state: LoadingState<UserModel> = .idle
    var isUpdating = false
    var alert: AlertModel?
    private let profileService: UserProfileService
    private let userState: UserState

    init(profileService: UserProfileService, userState: UserState) {
        self.profileService = profileService
        self.userState = userState
    }

    var user: UserModel? {
        if case .loaded(let user) = state { return user }
        return nil
    }

    var favouritesCount: Int { userState.likes.count }

    var websiteURL: URL? {
        guard let website = user?.userWebSite, !website.isEmpty else { return nil }
        return URL(string: website)
    }

    func loadUser() async {
        let isFirstLoad = user == nil
        if isFirstLoad { state = .loading }

        do {
            async let profile = profileService.loadProfile()
            async let likes: Void = userState.loadIfNeeded()
            let (loaded, _) = try await (profile, likes)
            state = .loaded(UserModel(profile: loaded))
        } catch {
            guard !error.isCancellation else {
                if isFirstLoad { state = .idle }
                return
            }
            guard isFirstLoad else { return }
            state = .failed(error)
            alert = .retryError(title: CatalogLocalizedText.loadError.resource) { [weak self] in
                Task { await self?.loadUser() }
            }
        }
    }

    func save(_ user: UserModel) async {
        isUpdating = true
        defer { isUpdating = false }
        do {
            let updated = try await profileService.updateProfile(
                name: user.username,
                description: user.bio,
                avatar: user.avatar,
                website: user.userWebSite
            )
            state = .loaded(UserModel(profile: updated))
        } catch {
            guard !error.isCancellation else { return }
            alert = .retryError(title: ProfileLocalizedText.saveError.resource) { [weak self] in
                Task { await self?.save(user) }
            }
        }
    }
}
