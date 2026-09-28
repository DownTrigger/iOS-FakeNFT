import SwiftUI

struct CollectionHeaderView: View {
    private static let coverHeight: CGFloat = 310
    private static let cornerRadius: CGFloat = 12

    let collection: NftCollection
    let onAuthorTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: collection.cover) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(.imgNFTPlaceholder)
                    .resizable()
                    .scaledToFill()
            }
            .frame(height: Self.coverHeight)
            .frame(maxWidth: .infinity)
            .clipShape(
                UnevenRoundedRectangle(bottomLeadingRadius: Self.cornerRadius, bottomTrailingRadius: Self.cornerRadius)
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(collection.name)
                    .font(.bold22)
                    .foregroundStyle(Color(.fnText))
                    .padding(.top, 16)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(localized: "Catalog.collectionAuthor"))
                        .font(.regular13)
                        .foregroundStyle(Color(.fnText))

                    Button(action: onAuthorTap) {
                        Text(collection.author)
                            .font(.regular15)
                            .foregroundStyle(Color(.fnBlue))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)

                Text(collection.description)
                    .font(.regular13)
                    .foregroundStyle(Color(.fnText))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    CollectionHeaderView(
        collection: NftCollection(
            id: "1",
            name: "Peach",
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
            nfts: (1...11).map(String.init),
            description: "Persik is a collection of pixel-art peaches.",
            author: "Lourdes Harper",
            website: "https://lourdes_harper.fakenfts.org/"
        ),
        onAuthorTap: {}
    )
}
