//
//  NFTCollectionItemRequest.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct NFTCollectionItemRequest: NetworkRequest {
    let id: String

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/nft/\(id)")
    }
}
