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
        let isFirstLoad = user == nil
        if isFirstLoad { state = .loading }

        do {
            let fetched = try await userService.loadUser()
            state = .loaded(fetched)
        } catch {
            if isFirstLoad { state = .failed(error) }
            // при фоновом обновлении ошибка не сбрасывает уже загруженный профиль
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

}
