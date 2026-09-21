import SwiftUI

struct NftGridCell: View {
    let model: NftGridCellModel
    let onLike: () -> Void
    let onCart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            image
            RatingView(rating: model.rating)
            info
        }
    }

    private var image: some View {
        // Временный загрузчик через AsyncImage: нужно будет заменить общим загрузчиком 
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: model.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(.imgNFTPlaceholder)
                    .resizable()
                    .scaledToFill()
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            LikeButton(isLiked: model.isLiked, action: onLike)
        }
    }

    private var info: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(Font(UIFont.bold17 as CTFont))
                    .foregroundStyle(Color(.fnText)) // шрифты нужно поменять будет после удаления UIKit модулей
                    .lineLimit(1)

                Text(model.priceText)
                    .font(Font(UIFont.medium10 as CTFont)) // шрифты нужно поменять будет после удаления UIKit модулей
                    .foregroundStyle(Color(.fnText))
            }

            Spacer()

            CartButton(isInCart: model.isInCart, action: onCart)
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
