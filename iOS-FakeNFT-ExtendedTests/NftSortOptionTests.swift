import XCTest
@testable import iOS_FakeNFT_Extended

final class NftSortOptionTests: XCTestCase {

    private let nfts: [Nft] = [
        Nft(id: "1", name: "Spring", images: [], description: "", rating: 3, price: 2, author: "1"),
        Nft(id: "2", name: "April", images: [], description: "", rating: 5, price: 1, author: "1"),
        Nft(id: "3", name: "Greena", images: [], description: "", rating: 1, price: 3, author: "1")
    ]

    func testSortByTitleOrdersAlphabetically() {
        // When
        let result = NftSortOption.byTitle.sorted(nfts)

        // Then
        XCTAssertEqual(result.map(\.id), ["2", "3", "1"])
    }

    func testSortByRatingOrdersDescending() {
        // When
        let result = NftSortOption.byRating.sorted(nfts)

        // Then
        XCTAssertEqual(result.map(\.id), ["2", "1", "3"])
    }

    func testSortByPriceOrdersDescending() {
        // When
        let result = NftSortOption.byPrice.sorted(nfts)

        // Then
        XCTAssertEqual(result.map(\.id), ["3", "1", "2"])
    }
}
