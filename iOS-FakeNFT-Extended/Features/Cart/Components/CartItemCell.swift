import SwiftUI

struct CartItemCell: View {
    let nft: CartNft
    let onDelete: () -> Void

    private let imageSize: CGFloat = 108

    var body: some View {
        HStack(spacing: 20) {
            image
            info
            Spacer()
            deleteButton
        }
        .padding(.vertical, 16)
    }

    private var image: some View {
        AsyncImage(url: nft.imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Image(.imgNFTPlaceholder)
                .resizable()
                .scaledToFill()
        }
        .frame(width: imageSize, height: imageSize)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(nft.name)
                    .font(.bold17)
                    .lineLimit(1)
                RatingView(rating: nft.rating)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(CartLocalizedText.price.key)
                    .font(.regular13)
                Text(PriceFormatter.string(from: nft.price))
                    .font(.bold17)
            }
        }
        .foregroundStyle(Color(.fnText))
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(.icCartDelete)
                .renderingMode(.template)
                .foregroundStyle(Color(.fnText))
                .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    CartItemCell(nft: .preview) {}
        .padding(.horizontal, 16)
}

extension CartNft {
    static let preview = CartNft(
        id: "1",
        name: "April",
        images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
        rating: 3,
        price: 1.78
    )
}
