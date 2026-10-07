import XCTest
@testable import iOS_FakeNFT_Extended

final class NftServiceTests: XCTestCase {

    func testLoadNftsKeepsOrderOfIdsRegardlessOfResponseDelay() async throws {
        // Given
        let service = RecordingNftService(delays: ["1": 30, "2": 20, "3": 10])

        // When
        let nfts = try await service.loadNfts(ids: ["1", "2", "3"])

        // Then
        XCTAssertEqual(nfts.map(\.id), ["1", "2", "3"])
    }

    func testLoadNftsKeepsDuplicatesButRequestsEachIdOnce() async throws {
        // Given
        let service = RecordingNftService()

        // When
        let nfts = try await service.loadNfts(ids: ["1", "2", "1", "1"])

        // Then
        XCTAssertEqual(nfts.map(\.id), ["1", "2", "1", "1"])
        let requested = await service.requestedIds
        XCTAssertEqual(requested.sorted(), ["1", "2"])
    }

    func testLoadNftsThrowsWhenAnyNftFails() async {
        // Given
        let service = RecordingNftService(failingId: "2")

        // When / Then
        do {
            _ = try await service.loadNfts(ids: ["1", "2", "3"])
            XCTFail("Expected error")
        } catch {
            guard case NetworkClientError.httpStatusCode(404) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testLoadNftsWithEmptyIdsReturnsEmptyList() async throws {
        // Given
        let service = RecordingNftService()

        // When
        let nfts = try await service.loadNfts(ids: [])

        // Then
        XCTAssertTrue(nfts.isEmpty)
        let requested = await service.requestedIds
        XCTAssertTrue(requested.isEmpty)
    }
}

private actor RecordingNftService: NftService {
    private let delays: [String: UInt64]
    private let failingId: String?
    private(set) var requestedIds: [String] = []

    init(delays: [String: UInt64] = [:], failingId: String? = nil) {
        self.delays = delays
        self.failingId = failingId
    }

    func loadNft(id: String) async throws -> Nft {
        requestedIds.append(id)
        if let delay = delays[id] {
            try await Task.sleep(for: .milliseconds(delay))
        }
        if id == failingId {
            throw NetworkClientError.httpStatusCode(404)
        }
        return .stub(id: id)
    }
}
