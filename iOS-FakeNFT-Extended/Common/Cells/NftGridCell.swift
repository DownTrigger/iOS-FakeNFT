import SwiftUI

struct NftGridCell: View {
    let model: NftGridCellModel
    let onLike: () -> Void
    let onCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            image
            RatingView(rating: model.rating)
                .padding(.top, 8)
            info
                .padding(.top, 4)
        }
    }

    private var image: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RemoteImageView(url: model.imageURL)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))

            LikeButton(isLiked: model.isLiked, action: onLike)
                .disabled(model.isLikePending)
                .opacity(model.isLikePending ? 0.5 : 1)
        }
    }

    private var info: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.bold17)
                    .foregroundStyle(Color(.fnText))
                    .lineLimit(1)

                Text(model.priceText)
                    .font(.medium10)
                    .foregroundStyle(Color(.fnText))
            }

            Spacer(minLength: 0)

            CartButton(isInCart: model.isInCart, action: onCart)
                .disabled(model.isCartPending)
                .opacity(model.isCartPending ? 0.5 : 1)
        }
    }
}

#Preview {
    @Previewable @State var isLiked = true
    @Previewable @State var isInCart = false

    NftGridCell(
        model: NftGridCellModel(
            id: "1",
            imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png"),
            name: "Emma",
            rating: 3,
            priceText: "1,78 ETH",
            isLiked: isLiked,
            isInCart: isInCart
        ),
        onLike: { isLiked.toggle() },
        onCart: { isInCart.toggle() }
    )
    .frame(width: 108)
    .padding()
}
