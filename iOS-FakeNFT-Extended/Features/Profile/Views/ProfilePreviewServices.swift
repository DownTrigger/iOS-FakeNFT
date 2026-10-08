struct ProfilePreviewUserProfileService: UserProfileService {
    private let profile = UserProfile(
        id: "1",
        name: "John Doe",
        description: "",
        website: nil,
        avatar: nil,
        nfts: ["1", "2", "3"],
        likes: ["1"]
    )

    func loadProfile() async throws -> UserProfile { profile }
    func updateLikes(_ change: IdChange) async throws -> UserProfile { profile }
    func updateProfile(
        name: String,
        description: String,
        avatar: String?,
        website: String?
    ) async throws -> UserProfile {
        profile
    }
}

struct ProfilePreviewUserOrderService: UserOrderService {
    private let order = UserOrder(id: "1", nfts: [])

    func loadOrder() async throws -> UserOrder { order }
    func updateNfts(_ change: IdChange) async throws -> UserOrder { order }
    func clearOrder() async throws -> UserOrder { order }
}
