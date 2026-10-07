//
//  UserResponse.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 02.10.2026.
//

import Foundation

struct UserResponse: Decodable, Sendable, Identifiable {
    let id: String
    let name: String
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatar
        case description
        case website
        case nfts
    }
}
