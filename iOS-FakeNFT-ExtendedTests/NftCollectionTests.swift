import XCTest
@testable import iOS_FakeNFT_Extended

final class NftCollectionTests: XCTestCase {

    func testDecodingRemovesDuplicateNftIdsKeepingOrder() throws {
        // Given
        let json = Data("""
        {
            "id": "1",
            "name": "Peach",
            "cover": "https://example.com/cover.png",
            "nfts": ["b", "a", "b", "c", "a"],
            "description": "Sample",
            "author": "John Doe",
            "website": "https://example.com"
        }
        """.utf8)

        // When
        let collection = try JSONDecoder().decode(NftCollection.self, from: json)

        // Then
        XCTAssertEqual(collection.nfts, ["b", "a", "c"])
        XCTAssertEqual(collection.nftCount, 3)
    }
}
