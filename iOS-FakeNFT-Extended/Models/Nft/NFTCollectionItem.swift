//
//  NFTCollectionItem.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct NFTCollectionItem: Decodable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Double
}
