import Kingfisher
import SwiftUI

struct CollectionCell: View {
    let collection: NftCollection

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            KFImage(collection.cover)
                .placeholder {
                    Image(.imgNFTPlaceholder)
                        .resizable()
                        .scaledToFill()
                }
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipShape(.rect(cornerRadius: 12))

            Text(verbatim: "\(collection.name) (\(collection.nftCount))")
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
        }
    }
}

#Preview {
    CollectionCell(
        collection: NftCollection(
            id: "1",
            name: "Peach",
            cover: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
            nfts: (1...11).map(String.init)
        )
    )
    .padding()
}
