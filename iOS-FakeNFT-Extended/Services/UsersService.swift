import Foundation

protocol UserServiceProtocol: Sendable {
    func loadUsers(page: Int, size: Int, sortBy: String?) async throws -> [UserResponse]
}

actor UsersServiceImpl: UserServiceProtocol {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadUsers(page: Int, size: Int, sortBy: String?) async throws -> [UserResponse] {
        let request = UsersRequest(page: page, size: size, sortBy: sortBy)

        return try await networkClient.send(
            request: request
        )
    }
}
