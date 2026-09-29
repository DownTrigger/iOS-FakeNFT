//
//  UserService.swift
//  iOS-FakeNFT-Extended
//

import Foundation

protocol UserService {
    func loadUser() async throws -> UserModel
    func updateUser(_ user: UserModel) async throws -> UserModel
}

@MainActor
final class UserServiceImpl: UserService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadUser() async throws -> UserModel {
        let request = ProfileRequest()
        return try await networkClient.send(request: request)
    }

    func updateUser(_ user: UserModel) async throws -> UserModel {
        let request = ProfileUpdate(user: user)
        return try await networkClient.send(request: request)
    }
}
