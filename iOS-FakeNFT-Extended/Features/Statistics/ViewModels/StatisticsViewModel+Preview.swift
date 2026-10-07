import Foundation

struct PreviewUserService: UserServiceProtocol {
    static let users: [UserResponse] = [
        UserResponse(
            id: "user-1",
            name: "Alex",
            avatar: "https://i.pravatar.cc/150?img=12",
            description: "Дизайнер из Казани, люблю цифровое искусство и бейглы. " +
            "В моей коллекции уже 100+ NFT, и еще больше — на моём сайте. Открыт к коллаборациям.",
            website: "https://www.apple.com",
            nfts: Array(repeating: "nft", count: 23)
        ),
        UserResponse(
            id: "user-2",
            name: "Igor",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 72)
        ),
        UserResponse(
            id: "user-3",
            name: "Natasha",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 71)
        ),
        UserResponse(
            id: "user-4",
            name: "Petr",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 98)
        ),
        UserResponse(
            id: "user-5",
            name: "Timothey",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 51)
        ),
        UserResponse(
            id: "user-6",
            name: "Olya",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 11)
        ),
        UserResponse(
            id: "user-7",
            name: "Zoya",
            avatar: nil,
            description: nil,
            website: nil,
            nfts: Array(repeating: "nft", count: 112)
        )
    ]

    func loadUsers(page: Int, size: Int, sortBy: String?) async throws -> [UserResponse] {
        let start = page * size
        guard start < Self.users.count else { return [] }
        return Array(Self.users[start..<min(start + size, Self.users.count)])
    }
}
