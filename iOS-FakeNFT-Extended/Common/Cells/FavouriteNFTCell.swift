import SwiftUI

struct FavouriteNFTCell: View {
    let model: NftGridCellModel
    let onLike: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RemoteImageView(url: model.imageURL)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                LikeButton(isLiked: model.isLiked, action: onLike)
                    .disabled(model.isLikePending)
                    .opacity(model.isLikePending ? 0.5 : 1)
                    .offset(x: 6, y: -6)
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
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
