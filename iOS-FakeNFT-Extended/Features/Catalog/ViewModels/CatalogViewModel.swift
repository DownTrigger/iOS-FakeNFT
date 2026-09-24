import Foundation

@MainActor
@Observable
final class CatalogViewModel {
    private(set) var collections: [NftCollection] = [
        NftCollection(id: "1", name: "Peach"),
        NftCollection(id: "2", name: "Blue"),
        NftCollection(id: "3", name: "Brown")
    ]
}
