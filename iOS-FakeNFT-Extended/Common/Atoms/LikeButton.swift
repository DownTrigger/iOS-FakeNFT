import SwiftUI

struct LikeButton: View {
    let isLiked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(.icHeart)
                .renderingMode(.template)
                .foregroundStyle(isLiked ? Color(.fnRed) : Color(.fnWhite))
        }
    }
}

#Preview {
    @Previewable @State var isLiked = false

    LikeButton(isLiked: isLiked) { isLiked.toggle() }
        .padding()
        .background(.fnGray)
}
