import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class NFTCollectionViewModelTests: XCTestCase {

    private func makeViewModel(
        ids: [String],
        service: NftService,
        likes: [String] = [],
        updateError: Error? = nil
    ) -> NFTCollectionViewModel {
        let userState = UserState(
            profileService: UserProfileServiceStub(likes: likes, updateError: updateError),
            orderService: UserOrderServiceStub()
        )
        return NFTCollectionViewModel(nftIds: ids, nftService: service, userState: userState)
    }

    func testLoadNftsKeepsIdsOrderAndFormatsPrice() async {
        // Given
        let viewModel = makeViewModel(ids: ["1", "2", "3"], service: NftServiceStub())

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.cells.map(\.id), ["1", "2", "3"])
        XCTAssertEqual(viewModel.cells.first?.priceText, PriceFormatter.string(from: 1.5))
        XCTAssertNil(viewModel.alert)
    }

    func testCellsReflectLikesFromProfile() async {
        // Given
        let viewModel = makeViewModel(ids: ["1", "2"], service: NftServiceStub(), likes: ["2"])

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [false, true])
    }

    func testLoadNftsFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let viewModel = makeViewModel(
            ids: ["1"],
            service: NftServiceStub(error: NetworkClientError.urlSessionError)
        )

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertTrue(viewModel.isFailed)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.cells.isEmpty)
    }

    func testToggleLikeUpdatesCell() async {
        // Given
        let viewModel = makeViewModel(ids: ["1"], service: NftServiceStub())
        await viewModel.loadNfts()

        // When
        await viewModel.toggleLike("1")

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [true])
        XCTAssertNil(viewModel.alert)
    }

    func testToggleLikeFailureRollsBackAndShowsAlert() async {
        // Given
        let viewModel = makeViewModel(
            ids: ["1"],
            service: NftServiceStub(),
            updateError: NetworkClientError.urlSessionError
        )
        await viewModel.loadNfts()

        // When
        await viewModel.toggleLike("1")

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [false])
        XCTAssertNotNil(viewModel.alert)
    }
}

private struct UserProfileServiceStub: UserProfileService {
    let likes: [String]
    var updateError: Error?

    func loadProfile() async throws -> UserProfile {
        UserProfile(id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [], likes: likes)
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        if let updateError {
            throw updateError
        }
        return UserProfile(
            id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [],
            likes: change.apply(to: likes)
        )
    }

    func updateProfile(name: String, description: String, avatar: String?, website: String?) async throws -> UserProfile {
        try await loadProfile()
    }
}

private struct UserOrderServiceStub: UserOrderService {
    func loadOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: [])
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        UserOrder(id: "1", nfts: change.apply(to: []))
    }

    func clearOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: [])
    }
}

private struct NftServiceStub: NftService {
    var error: Error?

    func loadNft(id: String) async throws -> Nft {
        if let error {
            throw error
        }
        return Nft(
            id: id,
            name: "NFT \(id)",
            images: [URL(string: "https://example.com/\(id).png")].compactMap { $0 },
            description: "",
            rating: 3,
            price: 1.5,
            author: "John Doe"
        )
    }
}
