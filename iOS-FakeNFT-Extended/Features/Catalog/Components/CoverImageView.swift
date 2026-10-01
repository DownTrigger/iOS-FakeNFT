import SwiftUI

struct CoverImageView: View {
    private static let maxReloadAttempts = 3

    let url: URL?

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
                    placeholder
                default:
                    loadingView
                }
            }
            .id(reloadAttempt)
        } else {
            placeholder
        }
    }

    private var loadingView: some View {
        ZStack {
            Color(.fnLightGray)
            ProgressView()
                .tint(Color(.fnText))
        }
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
