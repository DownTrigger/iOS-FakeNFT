import SwiftUI

struct RatingView: View {
    let rating: Int
    var maxRating = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(.icStar)
                    .renderingMode(.template)
                    .foregroundStyle(index < rating ? Color(.fnYellow) : Color(.fnLightGray))
            }
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        RatingView(rating: 0)
        RatingView(rating: 3)
        RatingView(rating: 5)
    }
}
