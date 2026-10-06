import SwiftUI

struct RemoteImageView: View {
    enum Placeholder {
        case nft
        case avatar
    }

    private static let maxReloadAttempts = 3

    let url: URL?
    var placeholder: Placeholder = .nft
    var showsProgress = false

    @State private var reloadAttempt = 0

    var body: some View {
        if let url {
            AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                case .failure(let error) where error.isCancellation && reloadAttempt < Self.maxReloadAttempts:
                    loadingView
                        .onAppear { reloadAttempt += 1 }
                case .failure:
                    placeholderImage
                default:
                    loadingView
                }
            }
            .id(reloadAttempt)
        } else {
            placeholderImage
        }
    }

    @ViewBuilder
    private var loadingView: some View {
        if showsProgress {
            ZStack {
                Color(.fnLightGray)
                ProgressView()
                    .tint(Color(.fnText))
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        Image(placeholderResource)
            .resizable()
            .scaledToFill()
    }

    private var placeholderResource: ImageResource {
        switch placeholder {
        case .nft: .imgNFTPlaceholder
        case .avatar: .imgAvatarPlaceholder
        }
    }
}

#Preview {
    VStack {
        RemoteImageView(
            url: URL(string: "https://code.s3.yandex.net/Mobile/iOS/NFT/Обложки_коллекций/Peach.png"),
            showsProgress: true
        )
        .frame(height: 140)
        RemoteImageView(url: nil, placeholder: .avatar)
            .frame(width: 70, height: 70)
            .clipShape(Circle())
    }
}
