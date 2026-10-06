//
//  UserResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct UserResponse: Decodable {
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case avatar
        case description
        case website
        case nfts
    }
}

protocol UserServiceProtocol {
    func loadUsers() async throws -> [UserResponse]
}

@MainActor
final class UsersServiceImpl: UserServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadUsers() async throws -> [UserResponse] {
        let request = UsersRequest()

        return try await networkClient.send(
            request: request
        )
    }
}
