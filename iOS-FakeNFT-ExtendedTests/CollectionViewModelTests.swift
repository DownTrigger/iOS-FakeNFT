import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class CollectionViewModelTests: XCTestCase {

    private func makeViewModel(
        collection: NftCollection,
        service: NftService,
        likes: [String] = [],
        cart: [String] = [],
        profileError: Error? = nil,
        updateError: Error? = nil,
        updateDelay: Duration = .zero
    ) -> CollectionViewModel {
        let userState = UserState(
            profileService: UserProfileServiceStub(
                likes: likes,
                error: profileError,
                updateError: updateError,
                updateDelay: updateDelay
            ),
            orderService: UserOrderServiceStub(nfts: cart, updateError: updateError)
        )
        return CollectionViewModel(collection: collection, nftService: service, userState: userState)
    }

    private func waitUntil(_ condition: () -> Bool, file: StaticString = #filePath, line: UInt = #line) async {
        for _ in 0..<200 {
            if condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Timed out waiting for condition", file: file, line: line)
    }

    func testLoadNftsKeepsCollectionOrder() async {
        // Given
        let service = NftServiceStub(delays: ["1": 30, "2": 20, "3": 10])
        let viewModel = makeViewModel(collection: .stub(nfts: ["1", "2", "3"]), service: service)

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.cells.map(\.id), ["1", "2", "3"])
        XCTAssertNil(viewModel.alert)
    }

    func testLoadNftsFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let service = NftServiceStub(error: NetworkClientError.urlSessionError)
        let viewModel = makeViewModel(collection: .stub(nfts: ["1"]), service: service)

        // When
        await viewModel.loadNfts()

        // Then
        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.cells.isEmpty)
    }

    func testLoadNftsCancellationDoesNotShowAlert() async {
        // Given
        let service = NftServiceStub(error: CancellationError())
        let viewModel = makeViewModel(collection: .stub(nfts: ["1"]), service: service)

        // When
        await viewModel.loadNfts()

        // Then
        guard case .idle = viewModel.state else {
            return XCTFail("Expected idle state")
        }
        XCTAssertNil(viewModel.alert)
    }

    func testLoadNftsDoesNotReloadLoadedNfts() async {
        // Given
        let service = NftServiceStub()
        let viewModel = makeViewModel(collection: .stub(nfts: ["1", "2"]), service: service)

        // When
        await viewModel.loadNfts()
        await viewModel.loadNfts()

        // Then
        let requestCount = await service.requestCount
        XCTAssertEqual(requestCount, 2)
    }

    func testCellsMapNftFields() async {
        // Given
        let service = NftServiceStub()
        let viewModel = makeViewModel(collection: .stub(nfts: ["1"]), service: service)

        // When
        await viewModel.loadNfts()

        // Then
        let cell = viewModel.cells.first
        XCTAssertEqual(cell?.name, "NFT 1")
        XCTAssertEqual(cell?.rating, 3)
        XCTAssertEqual(cell?.priceText, PriceFormatter.string(from: 1.5))
        XCTAssertEqual(cell?.imageURL, URL(string: "https://example.com/1.png"))
        XCTAssertEqual(cell?.isLiked, false)
        XCTAssertEqual(cell?.isInCart, false)
    }

    func testCellsReflectLikesAndCartFromUserState() async {
        // Given
        let viewModel = makeViewModel(
            collection: .stub(nfts: ["1", "2", "3"]),
            service: NftServiceStub(),
            likes: ["1", "2"],
            cart: ["2", "3"]
        )

        // When
        await viewModel.loadNfts()

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [true, true, false])
        XCTAssertEqual(viewModel.cells.map(\.isInCart), [false, true, true])
    }

    func testUserStateFailureSetsFailedStateAndShowsAlert() async {
        // Given
        let viewModel = makeViewModel(
            collection: .stub(nfts: ["1"]),
            service: NftServiceStub(),
            profileError: NetworkClientError.urlSessionError
        )

        // When
        await viewModel.loadNfts()

        // Then
        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.cells.isEmpty)
    }

    func testToggleLikeSuccessUpdatesCell() async {
        // Given
        let viewModel = makeViewModel(collection: .stub(nfts: ["1"]), service: NftServiceStub())
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
            collection: .stub(nfts: ["1"]),
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

    func testToggleCartSuccessUpdatesCell() async {
        // Given
        let viewModel = makeViewModel(collection: .stub(nfts: ["1"]), service: NftServiceStub())
        await viewModel.loadNfts()

        // When
        await viewModel.toggleCart("1")

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isInCart), [true])
        XCTAssertNil(viewModel.alert)
    }

    func testToggleCartFailureRollsBackAndShowsAlert() async {
        // Given
        let viewModel = makeViewModel(
            collection: .stub(nfts: ["1"]),
            service: NftServiceStub(),
            updateError: NetworkClientError.urlSessionError
        )
        await viewModel.loadNfts()

        // When
        await viewModel.toggleCart("1")

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isInCart), [false])
        XCTAssertNotNil(viewModel.alert)
    }

    func testRepeatedLikeTapWhileRequestIsPendingIsIgnored() async {
        // Given
        let viewModel = makeViewModel(
            collection: .stub(nfts: ["1"]),
            service: NftServiceStub(),
            updateDelay: .milliseconds(100)
        )
        await viewModel.loadNfts()

        // When
        let firstTap = Task { await viewModel.toggleLike("1") }
        await waitUntil { viewModel.cells.first?.isLikePending == true }
        await viewModel.toggleLike("1")

        // Then
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [true])
        await firstTap.value
        XCTAssertEqual(viewModel.cells.map(\.isLiked), [true])
        XCTAssertEqual(viewModel.cells.map(\.isLikePending), [false])
    }
}

private struct UserProfileServiceStub: UserProfileService {
    let likes: [String]
    let error: Error?
    var updateError: Error?
    var updateDelay: Duration = .zero

    func loadProfile() async throws -> UserProfile {
        if let error {
            throw error
        }
        return UserProfile(id: "1", name: "Name", description: "", website: nil, avatar: nil, nfts: [], likes: likes)
    }

    func updateLikes(_ change: IdChange) async throws -> UserProfile {
        try await Task.sleep(for: updateDelay)
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
    let nfts: [String]
    var updateError: Error?

    func loadOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: nfts)
    }

    func updateNfts(_ change: IdChange) async throws -> UserOrder {
        if let updateError {
            throw updateError
        }
        return UserOrder(id: "1", nfts: change.apply(to: nfts))
    }

    func clearOrder() async throws -> UserOrder {
        UserOrder(id: "1", nfts: [])
    }
}

private actor NftServiceStub: NftService {
    private let delays: [String: Int]
    private let error: Error?
    private(set) var requestCount = 0

    init(delays: [String: Int] = [:], error: Error? = nil) {
        self.delays = delays
        self.error = error
    }

    func loadNft(id: String) async throws -> Nft {
        requestCount += 1
        if let error {
            throw error
        }
        if let delay = delays[id] {
            try await Task.sleep(for: .milliseconds(delay))
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

private extension NftCollection {
    static func stub(nfts: [String]) -> NftCollection {
        NftCollection(
            id: "1",
            name: "Peach",
            cover: nil,
            nfts: nfts,
            description: "",
            author: "John Doe",
            website: "https://example.com"
        )
    }
}
