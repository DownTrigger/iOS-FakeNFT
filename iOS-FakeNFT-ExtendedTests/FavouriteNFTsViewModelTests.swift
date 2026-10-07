import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class FavouriteNFTsViewModelTests: XCTestCase {

    private func makeViewModel(likes: [String]) -> FavouriteNFTsViewModel {
        let profileService = ProfileServiceStub(likes: likes)
        let userState = UserState(profileService: profileService, orderService: OrderServiceStub())
        return FavouriteNFTsViewModel(
            nftService: NftServiceStub(),
            profileService: profileService,
            userState: userState
        )
    }

    func testDisplayedNftsFollowProfileLikesOrder() async {
        // Given
        let viewModel = makeViewModel(likes: ["3", "1", "2"])

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.displayedNfts.map(\.id), ["3", "1", "2"])
        XCTAssertNil(viewModel.alert)
    }

    func testToggleLikeRemovesNftFromDisplayedNfts() async {
        // Given
        let viewModel = makeViewModel(likes: ["1", "2"])
        await viewModel.loadNfts()
        guard let nft = viewModel.displayedNfts.first else {
            return XCTFail("Expected loaded nfts")
        }

        // When
        await viewModel.toggleLike(nft)

        // Then
        XCTAssertEqual(viewModel.displayedNfts.map(\.id), ["2"])
        XCTAssertNil(viewModel.alert)
    }
}

private struct ProfileServiceStub: UserProfileService {
    let likes: [String]

    func loadProfile() async throws -> UserProfile {
        UserProfile(id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [], likes: likes)
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        UserProfile(
            id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [],
            likes: change.apply(to: likes)
        )
    }

    func updateProfile(name: String, description: String, avatar: String?, website: String?) async throws -> UserProfile {
        try await loadProfile()
    }
}

private struct OrderServiceStub: UserOrderService {
    func loadOrder() async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
    func updateNfts(_ change: IdChange) async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
    func clearOrder() async throws -> UserOrder { UserOrder(id: "1", nfts: []) }
}

private struct NftServiceStub: NftService {
    func loadNft(id: String) async throws -> Nft {
        Nft(
            id: id,
            name: "NFT \(id)",
            images: [],
            description: "",
            rating: 3,
            price: 1.5,
            author: "John Doe"
        )
    }
}
