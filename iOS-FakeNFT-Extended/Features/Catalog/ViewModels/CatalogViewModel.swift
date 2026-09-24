import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private(set) var sortOption: CatalogSortOption = .byNftCount

    func selectSort(_ option: CatalogSortOption) {
        sortOption = option
    }

    private(set) var collections: [NftCollection] = [
        NftCollection(
            id: "1",
            name: "Peach",
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
            nfts: (1...11).map(String.init)
        ),
        NftCollection(
            id: "2",
            name: "Blue",
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Blue.png"),
            nfts: (1...6).map(String.init)
        ),
        NftCollection(
            id: "3",
            name: "Brown",
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Brown.png"),
            nfts: (1...8).map(String.init)
        )
    ]
}
