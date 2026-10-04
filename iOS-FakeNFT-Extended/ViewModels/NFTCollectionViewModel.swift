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

    func load(nftIDs: [String]) async {
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

            nftItems = responses.map { nft in
                NftGridCellModel(
                    id: nft.id,
                    imageURL: nft.images.first,
                    name: nft.name,
                    rating: nft.rating,
                    priceText: "\(nft.price)",
                    isLiked: false,
                    isInCart: false
                )
            }
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
