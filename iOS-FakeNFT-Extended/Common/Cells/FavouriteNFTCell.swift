//
//  FavouriteNFTCell.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct FavouriteNFTCell: View {
    let model: NftGridCellModel
    let onLike: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: model.imageURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(.imgNFTPlaceholder).resizable().scaledToFill()
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                LikeButton(isLiked: model.isLiked, action: onLike)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(model.name)
                    .font(.bold17)
                    .foregroundStyle(Color(.fnText))
                    .lineLimit(1)
                    .padding(.bottom, 4)

                RatingView(rating: model.rating)
                    .padding(.bottom, 8)

                Text(model.priceText)
                    .font(.regular15)
                    .foregroundStyle(Color(.fnText))
            }

            Spacer(minLength: 0)
        }
    }
}
