import Foundation

protocol UserProfileService: Sendable {
    func loadProfile() async throws -> UserProfile
    func updateLikes(_ change: IdChange) async throws -> UserProfile
}

actor UserProfileServiceImpl: UserProfileService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile() async throws -> UserProfile {
        try await networkClient.send(request: UserProfileRequest())
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        let profile = try await loadProfile()
        let likes = change.apply(to: profile.likes)
        guard likes != profile.likes else {
            return profile
        }
        let request = UserProfileUpdateRequest(profile: profile, likes: likes)
        return try await networkClient.send(request: request)
    }
}
