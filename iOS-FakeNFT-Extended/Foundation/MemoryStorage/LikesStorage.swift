//
//  LikesStorage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 04.10.2026.
//

import Foundation

protocol LikesStorage: AnyObject, Sendable {
    func saveLikes(_ likes: [String]) async
    func getLikes() async -> [String]
    func isLiked(nftID: String) async -> Bool
}

actor LikesStorageImpl: LikesStorage {
    private var likes: Set<String> = []

    func saveLikes(_ likes: [String]) async {
        self.likes = Set(likes)
    }

    func getLikes() async -> [String] {
        Array(likes)
    }

    func isLiked(nftID: String) async -> Bool {
        likes.contains(nftID)
    }
}
