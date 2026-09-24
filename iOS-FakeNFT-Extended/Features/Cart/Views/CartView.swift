import SwiftUI

struct CartView: View {
    var body: some View {
        Text(TabLocalizedText.cart.key)
            .font(.bold17)
            .foregroundStyle(Color(.fnText))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.fnBackground))
    }
}
