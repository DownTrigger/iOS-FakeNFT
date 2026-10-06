//
//  ProfileResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 04.10.2026.
//

import Foundation

// TODO: временный вариант, заменить на код эпика Profile - это его ответственность
struct ProfileResponse: Decodable {
    let likes: [String]
}


protocol ProfileService {
    func loadProfile() async throws -> ProfileResponse
}

@MainActor
final class ProfileServiceImpl: ProfileService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile() async throws -> ProfileResponse {
        let request = ProfileRequest()

        return try await networkClient.send(
            request: request
        )
    }
}
