//
//  CollectionMenu.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct CollectionMenu: View {

    let nftCount: Int
    let favouritesCount: Int
    let onMyNFTs: () -> Void
    let onFavouriteNFTs: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            CollectionMenuRow(
                item: UserCollectionMenuModel(title: "Мои NFT", count: nftCount),
                action: onMyNFTs
            )
            CollectionMenuRow(
                item: UserCollectionMenuModel(title: "Избранные NFT", count: favouritesCount),
                action: onFavouriteNFTs
            )
        }
    }
}

struct CollectionMenuRow: View {
    let item: UserCollectionMenuModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(item.title)
                Text("(\(item.count))")

                Spacer()

                Image(systemName: "chevron.right")
            }
            .font(.system(size: 17, weight: .bold))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
    }
}

#Preview("Main") {
    CollectionMenu(
        nftCount: 5,
        favouritesCount: 3,
        onMyNFTs: {},
        onFavouriteNFTs: {}
    )
}

#Preview("Row") {
    CollectionMenuRow(item: UserCollectionMenuModel(title: "My NFTs", count: 112), action: {})
}
