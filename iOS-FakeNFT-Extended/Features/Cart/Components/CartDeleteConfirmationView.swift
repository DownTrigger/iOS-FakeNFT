import SwiftUI

struct CartDeleteConfirmationView: View {
    let nft: Nft
    var isDeleting = false
    let onDelete: () -> Void
    let onCancel: () -> Void

    private let imageSize: CGFloat = 108
    private let buttonSize = CGSize(width: 127, height: 44)
    private let verticalOffset: CGFloat = -52

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                image
                Text(CartLocalizedText.deleteConfirmation.key)
                    .font(.regular13)
                    .foregroundStyle(Color(.fnText))
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 8) {
                button(CartLocalizedText.delete, color: Color(.fnRed), action: onDelete)
                button(CartLocalizedText.back, color: Color(.fnBackground), action: onCancel)
            }
            .disabled(isDeleting)
        }
        .offset(y: verticalOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var image: some View {
        AsyncImage(url: nft.images.first) { image in
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

    private func button(_ title: CartLocalizedText, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title.key)
                .font(.regular17)
                .foregroundStyle(color)
                .frame(width: buttonSize.width, height: buttonSize.height)
                .background(Color(.fnText))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    CartDeleteConfirmationView(
        nft: Nft(
            id: "1",
            name: "April",
            images: [URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Beige/April/1.png")].compactMap { $0 },
            description: "",
            rating: 3,
            price: 1.78,
            author: "1"
        ),
        onDelete: {},
        onCancel: {}
    )
    .background(.ultraThinMaterial)
}
