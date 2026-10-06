//
//  NFTCollectionViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

@MainActor
@Observable
final class NFTCollectionViewModel {
    var nftItems: [NftGridCellModel] = []
    var isLoading = false
    var error: Error?

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func load(
        nftIDs: [String],
        isLiked: @escaping (String) async -> Bool,
        isInCart: @escaping (String) async -> Bool
    ) async {
        isLoading = true
        error = nil

        do {
            let responses = try await withThrowingTaskGroup(
                of: Nft.self
            ) { group in
                for id in nftIDs {
                    group.addTask {
                        let request = NFTRequest(id: id)

                        let nft: Nft = try await self.networkClient.send(
                            request: request
                        )

                        return nft
                    }
                }

                var result: [Nft] = []

                for try await response in group {
                    result.append(response)
                }

                return result
            }

            var items: [NftGridCellModel] = []

            for nft in responses {
                let liked = await isLiked(nft.id)
                let inCart = await isInCart(nft.id)

                let item = NftGridCellModel(
                    id: nft.id,
                    imageURL: nft.images.first,
                    name: nft.name,
                    rating: nft.rating,
                    priceText: "\(nft.price)",
                    isLiked: liked,
                    isInCart: inCart
                )

                items.append(item)
            }

            nftItems = items
        } catch {
            self.error = error
            print("NFT load error:", error)
        }

        isLoading = false
    }
}
