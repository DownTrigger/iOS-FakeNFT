import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class StatisticsViewModelTests: XCTestCase {
    func testApplySortByRatingLoadsAllPagesAndSortsByNftCount() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)

        // When
        await viewModel.applySort(.byRating)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests, [
            .init(page: 0, sortBy: nil),
            .init(page: 1, sortBy: nil),
            .init(page: 2, sortBy: nil)
        ])
        XCTAssertEqual(viewModel.statistics.count, 30)
        XCTAssertEqual(viewModel.statistics.map(\.position), Array(1...30))
        XCTAssertEqual(viewModel.statistics.map(\.id), (0..<30).reversed().map { "user-\($0)" })
        XCTAssertFalse(viewModel.isInitialLoading)
    }

    func testApplySortByNameLoadsFirstPageWithServerOrder() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)

        // When
        await viewModel.applySort(.byName)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests, [.init(page: 0, sortBy: "name,asc")])
        XCTAssertEqual(viewModel.statistics.count, 25)
        XCTAssertEqual(viewModel.statistics.map(\.position), Array(1...25))
        XCTAssertEqual(viewModel.statistics.map(\.id), (0..<25).map { "user-\($0)" })
        XCTAssertFalse(viewModel.isInitialLoading)
    }

    func testLoadNextPageIfNeededLoadsNextPageForLastItem() async throws {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byName)
        let firstItem = try XCTUnwrap(viewModel.statistics.first)
        let lastItem = try XCTUnwrap(viewModel.statistics.last)

        // When
        await viewModel.loadNextPageIfNeeded(currentItem: firstItem)
        let requestsAfterFirstItem = await service.requests.count
        await viewModel.loadNextPageIfNeeded(currentItem: lastItem)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requestsAfterFirstItem, 1)
        XCTAssertEqual(requests.map(\.page), [0, 1])
        XCTAssertEqual(viewModel.statistics.map(\.position), Array(1...30))
    }

    func testApplySortByNameRecreatesPagination() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byRating)

        // When
        await viewModel.applySort(.byName)

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests.last, .init(page: 0, sortBy: "name,asc"))
        XCTAssertEqual(viewModel.statistics.count, 25)
    }

    func testIncompletePageDoesNotStopLoadingNextPage() async throws {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30), pageSizeLimit: 24)
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byName)
        let lastItem = try XCTUnwrap(viewModel.statistics.last)

        // When
        await viewModel.loadNextPageIfNeeded(currentItem: lastItem)

        // Then
        let requests = await service.requests
        XCTAssertEqual(viewModel.statistics.count, 29)
        XCTAssertEqual(requests.map(\.page), [0, 1])
    }

    func testFirstPageFailureSetsLoadErrorAndShowsAlert() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30), failingPage: 0)
        let viewModel = StatisticsViewModel(userService: service)

        // When
        await viewModel.applySort(.byRating)

        // Then
        XCTAssertTrue(viewModel.hasLoadError)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.statistics.isEmpty)
        XCTAssertFalse(viewModel.isInitialLoading)
    }

    func testNextPageFailureKeepsItemsAndShowsAlertWithoutLoadError() async throws {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30), failingPage: 1)
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byName)
        let lastItem = try XCTUnwrap(viewModel.statistics.last)

        // When
        await viewModel.loadNextPageIfNeeded(currentItem: lastItem)

        // Then
        XCTAssertFalse(viewModel.hasLoadError)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertEqual(viewModel.statistics.count, 25)
    }

    func testRefreshFailureKeepsStatisticsAndShowsAlert() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byName)
        await service.setFailingPage(0)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertEqual(viewModel.statistics.count, 25)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertFalse(viewModel.hasLoadError)
    }

    func testRefreshReloadsFirstPageWithSameSort() async {
        // Given
        let service = UserServiceStub(users: makeUsers(count: 30))
        let viewModel = StatisticsViewModel(userService: service)
        await viewModel.applySort(.byName)

        // When
        await viewModel.refresh()

        // Then
        let requests = await service.requests
        XCTAssertEqual(requests.map(\.sortBy), ["name,asc", "name,asc"])
        XCTAssertEqual(requests.map(\.page), [0, 0])
        XCTAssertEqual(viewModel.statistics.count, 25)
    }

    func testStatisticsMapUserFields() async throws {
        // Given
        let user = UserResponse(
            id: "a",
            name: "Anna",
            avatar: "avatar-url",
            description: nil,
            website: "https://example.com",
            nfts: ["1", "2"]
        )
        let service = UserServiceStub(users: [user])
        let viewModel = StatisticsViewModel(userService: service)

        // When
        await viewModel.applySort(.byRating)

        // Then
        let statistic = try XCTUnwrap(viewModel.statistics.first)
        XCTAssertEqual(statistic.id, "a")
        XCTAssertEqual(statistic.user.username, "Anna")
        XCTAssertEqual(statistic.user.avatar, "avatar-url")
        XCTAssertEqual(statistic.user.bio, "")
        XCTAssertEqual(statistic.user.userWebSite, "https://example.com")
        XCTAssertEqual(statistic.nfts, ["1", "2"])
    }

    private func makeUsers(count: Int) -> [UserResponse] {
        (0..<count).map { index in
            UserResponse(
                id: "user-\(index)",
                name: "User \(index)",
                avatar: nil,
                description: nil,
                website: nil,
                nfts: (0..<index).map { "nft-\($0)" }
            )
        }
    }
}

private actor UserServiceStub: UserServiceProtocol {
    struct Request: Equatable {
        let page: Int
        let sortBy: String?
    }

    private let users: [UserResponse]
    private let pageSizeLimit: Int?
    private var failingPage: Int?
    private(set) var requests: [Request] = []

    init(users: [UserResponse], pageSizeLimit: Int? = nil, failingPage: Int? = nil) {
        self.users = users
        self.pageSizeLimit = pageSizeLimit
        self.failingPage = failingPage
    }

    func setFailingPage(_ page: Int?) {
        failingPage = page
    }

    func loadUsers(page: Int, size: Int, sortBy: String?) async throws -> [UserResponse] {
        requests.append(Request(page: page, sortBy: sortBy))
        if page == failingPage { throw NetworkClientError.urlSessionError }
        let start = page * size
        guard start < users.count else { return [] }
        let count = min(pageSizeLimit ?? size, size)
        return Array(users[start..<min(start + count, users.count)])
    }
}
