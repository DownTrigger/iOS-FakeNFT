import SwiftUI

struct CartButton: View {
    let isInCart: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(isInCart ? .icCartDelete : .icCart)
                .renderingMode(.template)
                .foregroundStyle(Color(.fnText))
        }
    }
}

#Preview {
    @Previewable @State var isInCart = false

    CartButton(isInCart: isInCart) { isInCart.toggle() }
        .padding()
}
