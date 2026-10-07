import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class ProfileViewModelTests: XCTestCase {

    private func makeViewModel(service: ProfileServiceStub) -> ProfileViewModel {
        let userState = UserState(profileService: service, orderService: OrderServiceStub())
        return ProfileViewModel(profileService: service, userState: userState)
    }

    func testLoadUserSetsLoadedStateAndFavouritesCount() async {
        // Given
        let service = ProfileServiceStub(profile: .stub(name: "Alice", likes: ["1", "2", "3"]))
        let viewModel = makeViewModel(service: service)

        // When
        await viewModel.loadUser()

        // Then
        XCTAssertEqual(viewModel.user?.username, "Alice")
        XCTAssertEqual(viewModel.favouritesCount, 3)
        XCTAssertNil(viewModel.alert)
    }

    func testLoadUserFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let service = ProfileServiceStub(profile: .stub(), loadError: NetworkClientError.urlSessionError)
        let viewModel = makeViewModel(service: service)

        // When
        await viewModel.loadUser()

        // Then
        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertNotNil(viewModel.alert)
    }

    func testSaveCallsUpdateProfileAndUpdatesState() async {
        // Given
        let service = ProfileServiceStub(profile: .stub(name: "Alice", likes: ["1"]))
        let viewModel = makeViewModel(service: service)
        await viewModel.loadUser()
        let edited = UserModel(
            avatar: "https://example.com/a.png",
            username: "Bob",
            bio: "Bio",
            userWebSite: "https://example.com",
            nfts: [],
            likes: ["1"]
        )

        // When
        await viewModel.save(edited)

        // Then
        let calls = await service.updateProfileCalls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(calls.first?.name, "Bob")
        XCTAssertEqual(calls.first?.description, "Bio")
        XCTAssertEqual(calls.first?.avatar, "https://example.com/a.png")
        XCTAssertEqual(calls.first?.website, "https://example.com")
        let likesCalls = await service.updateLikesCallCount
        XCTAssertEqual(likesCalls, 0)
        XCTAssertEqual(viewModel.user?.username, "Bob")
        XCTAssertFalse(viewModel.isUpdating)
        XCTAssertNil(viewModel.alert)
    }

    func testSaveFailureKeepsLoadedStateAndShowsAlert() async {
        // Given
        let service = ProfileServiceStub(
            profile: .stub(name: "Alice"),
            updateError: NetworkClientError.urlSessionError
        )
        let viewModel = makeViewModel(service: service)
        await viewModel.loadUser()
        let edited = UserModel(avatar: nil, username: "Bob", bio: "", userWebSite: nil, nfts: [], likes: [])

        // When
        await viewModel.save(edited)

        // Then
        guard case .loaded = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        XCTAssertEqual(viewModel.user?.username, "Alice")
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.isUpdating)
    }
}

private extension UserProfile {
    static func stub(name: String = "Name", likes: [String] = []) -> UserProfile {
        UserProfile(id: "1", name: name, description: "", website: nil, avatar: nil, nfts: [], likes: likes)
    }
}

private struct UpdateProfileCall: Sendable {
    let name: String
    let description: String
    let avatar: String?
    let website: String?
}

private actor ProfileServiceStub: UserProfileService {
    private var profile: UserProfile
    private let loadError: Error?
    private let updateError: Error?
    private(set) var updateProfileCalls: [UpdateProfileCall] = []
    private(set) var updateLikesCallCount = 0

    init(profile: UserProfile, loadError: Error? = nil, updateError: Error? = nil) {
        self.profile = profile
        self.loadError = loadError
        self.updateError = updateError
    }

    func loadProfile() async throws -> UserProfile {
        if let loadError {
            throw loadError
        }
        return profile
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        updateLikesCallCount += 1
        return profile
    }

    func updateProfile(name: String, description: String, avatar: String?, website: String?) async throws -> UserProfile {
        updateProfileCalls.append(UpdateProfileCall(name: name, description: description, avatar: avatar, website: website))
        if let updateError {
            throw updateError
        }
        profile = UserProfile(
            id: profile.id,
            name: name,
            description: description,
            website: website,
            avatar: avatar,
            nfts: profile.nfts,
            likes: profile.likes
        )
        return profile
    }
}

private struct OrderServiceStub: UserOrderService {
    func loadOrder() async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
    func updateNfts(_ change: IdChange) async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
    func clearOrder() async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
}
