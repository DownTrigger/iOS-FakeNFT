import SwiftUI

struct EmptyStateView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(Font(UIFont.bold17 as CTFont))
            .foregroundStyle(Color(.fnText))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
}

#Preview {
    EmptyStateView(message: "У вас ещё нет NFT")
}
