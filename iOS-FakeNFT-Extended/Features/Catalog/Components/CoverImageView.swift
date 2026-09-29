import SwiftUI

struct CoverImageView: View {
    let url: URL?

    @State private var reloadID = 0

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure(let error) where error.isCancellation:
                placeholder
                    .onAppear { reloadID += 1 }
            default:
                placeholder
            }
        }
        .id(reloadID)
    }

    private var placeholder: some View {
        Image(.imgNFTPlaceholder)
            .resizable()
            .scaledToFill()
    }
}

#Preview {
    CoverImageView(url: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"))
        .frame(height: 140)
}
