import SwiftUI

struct MyNFTListCell: View {
    let nft: Nft
    let isLiked: Bool
    var isLikePending = false
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            image
            info
                .frame(maxWidth: .infinity, alignment: .leading)
            price
                .fixedSize()
                .frame(minWidth: 90, alignment: .leading)
        }
    }

    private var image: some View {
        ZStack(alignment: .topTrailing) {
            RemoteImageView(url: nft.images.first)
                .frame(width: 108, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            LikeButton(isLiked: isLiked, action: onLike)
                .disabled(isLikePending)
                .opacity(isLikePending ? 0.5 : 1)
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nft.name)
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
                .lineLimit(1)
            RatingView(rating: nft.rating)
            Text(ProfileLocalizedText.nftAuthor(nft.author).key)
                .font(.regular13)
                .foregroundStyle(Color(.fnText))
                .lineLimit(1)
        }
    }

    private var price: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ProfileLocalizedText.nftPrice.key)
                .font(.regular13)
                .foregroundStyle(Color(.fnText))
            Text(PriceFormatter.string(from: nft.price))
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
        }
    }
}
