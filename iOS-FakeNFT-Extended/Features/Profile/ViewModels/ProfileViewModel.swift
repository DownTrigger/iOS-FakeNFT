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
    var showMyNFTs = false
    private var userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
    }
    
    var user: UserModel? {
        if case .loaded(let user) = state { return user }
        return nil
    }
    
    var websiteURL: URL? {
        guard let website = user?.userWebSite, !website.isEmpty else { return nil }
        return URL(string: website)
    }
    
    func loadUser() async {
        state = .loading
        do {
            let user = try await userService.loadUser()
            state = .loaded(user)
        } catch {
            state = .failed(error)
        }
    }
    
    func updateUser(_ user: UserModel) {
        Task {
            isUpdating = true
            do {
                let updated = try await userService.updateUser(user)
                state = .loaded(updated)
            } catch {
                state = .failed(error)
            }
            isUpdating = false
        }
    }

    func openMyNFTs() {
        showMyNFTs = true
    }

    func openFavouriteNFTs() {
        // TODO: nav to nft list
    }
}
