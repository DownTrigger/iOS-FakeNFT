//
//  StatisticsViewModelTests.swift
//  iOS-FakeNFT-ExtendedTests
//
//  Created by Irina Muravyeva on 05.10.2026.
//

import XCTest
@testable import iOS_FakeNFT_Extended

@MainActor
final class StatisticsViewModelTests: XCTestCase {
    func testLoadStatistics_success_loadsUsersAndCreatesStatistics() async {
        // Given
        let users = [
            makeUser(
                name: "Anna",
                nfts: ["1", "2", "3"]
            ),
            makeUser(
                name: "Maria",
                nfts: ["4"]
            )
        ]

        let service = MockUserService()
        service.result = .success(users)

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 1)
        XCTAssertEqual(viewModel.statistics.count, 2)

        XCTAssertEqual(viewModel.statistics[0].user.username, "Anna")
        XCTAssertEqual(viewModel.statistics[0].nfts.count, 3)
        XCTAssertEqual(viewModel.statistics[0].position, 1)

        XCTAssertEqual(viewModel.statistics[1].user.username, "Maria")
        XCTAssertEqual(viewModel.statistics[1].nfts.count, 1)
        XCTAssertEqual(viewModel.statistics[1].position, 2)

        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadStatistics_mapsUserDataCorrectly() async {
        // Given
        let user = makeUser(
            name: "Anna",
            avatar: "avatar-url",
            description: "My bio",
            website: "https://example.com",
            nfts: ["1", "2", "3"]
        )

        let service = MockUserService()
        service.result = .success([user])

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        let statistic = viewModel.statistics[0]

        XCTAssertEqual(statistic.user.username, "Anna")
        XCTAssertEqual(statistic.user.avatar, "avatar-url")
        XCTAssertEqual(statistic.user.bio, "My bio")
        XCTAssertEqual(statistic.user.userWebSite, "https://example.com")
        XCTAssertEqual(statistic.nfts, ["1", "2", "3"])
    }
    
    func testLoadStatistics_nilDescription_setsEmptyBio() async {
        // Given
        let user = makeUser(
            name: "Anna",
            description: nil,
            nfts: ["1"]
        )

        let service = MockUserService()
        service.result = .success([user])

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(
            viewModel.statistics[0].user.bio,
            ""
        )
    }
    
    func testLoadStatistics_emptyResponse_returnsEmptyStatistics() async {
        // Given
        let service = MockUserService()
        service.result = .success([])

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 1)
        XCTAssertTrue(viewModel.statistics.isEmpty)
        XCTAssertNil(viewModel.alert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadStatistics_failure_setsAlert() async {
        // Given
        let service = MockUserService()
        service.result = .failure(
            URLError(.notConnectedToInternet)
        )

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 1)
        XCTAssertNotNil(viewModel.alert)
        XCTAssertTrue(viewModel.statistics.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadStatistics_cancellation_doesNotSetAlert() async {
        // Given
        let service = MockUserService()
        service.result = .failure(CancellationError())

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertNil(viewModel.alert)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadStatistics_whenAlreadyLoaded_doesNotLoadAgain() async {
        // Given
        let users = [
            makeUser(
                name: "Anna",
                nfts: ["1", "2"]
            )
        ]

        let service = MockUserService()
        service.result = .success(users)

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 1)
    }
    
    func testRefreshStatistics_loadsUsersAgain() async {
        // Given
        let users = [
            makeUser(
                name: "Anna",
                nfts: ["1"]
            )
        ]

        let service = MockUserService()
        service.result = .success(users)

        let viewModel = StatisticsViewModel(
            userService: service
        )

        // When
        await viewModel.loadStatistics()
        await viewModel.refreshStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 2)
    }
    
    func testResetCache_allowsLoadingAgain() async {
        // Given
        let users = [
            makeUser(
                name: "Anna",
                nfts: ["1", "2"]
            )
        ]

        let service = MockUserService()
        service.result = .success(users)

        let viewModel = StatisticsViewModel(
            userService: service
        )

        await viewModel.loadStatistics()
        XCTAssertEqual(service.loadUsersCallCount, 1)

        // When
        viewModel.resetCache()
        await viewModel.loadStatistics()

        // Then
        XCTAssertEqual(service.loadUsersCallCount, 2)
    }
}

extension StatisticsViewModelTests {
    private func makeUser(
        name: String,
        avatar: String? = nil,
        description: String? = nil,
        website: String? = nil,
        nfts: [String] = []
    ) -> UserResponse {
        UserResponse(
            name: name,
            avatar: avatar,
            description: description,
            website: website,
            nfts: nfts
        )
    }
}

@MainActor
final class MockUserService: UserServiceProtocol {
    var loadUsersCallCount = 0
    var result: Result<[UserResponse], Error> = .success([])

    func loadUsers() async throws -> [UserResponse] {
        loadUsersCallCount += 1
        return try result.get()
    }
}
