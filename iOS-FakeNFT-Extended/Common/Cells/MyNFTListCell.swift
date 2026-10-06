//
//  MyNFTListCell.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct MyNFTListCell: View {
    let nft: Nft
    let isLiked: Bool
    let username: String
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            image
            info
            Spacer()
            price
        }
    }

    private var image: some View {
        ZStack(alignment: .topTrailing) {
            RemoteImageView(url: nft.images.first)
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            LikeButton(isLiked: isLiked, action: onLike)
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nft.name)
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
            RatingView(rating: nft.rating)
            Text("от \(nft.author)")
                .font(.regular13)
                .foregroundStyle(Color(.fnText))
        }
    }

    private var price: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Цена")
                .font(.regular13)
                .foregroundStyle(Color(.fnText))
            Text(PriceFormatter.string(from: nft.price))
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
        }
    }
}
