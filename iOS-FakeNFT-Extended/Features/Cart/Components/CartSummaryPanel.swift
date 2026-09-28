import SwiftUI

struct CartSummaryPanel: View {
    let count: Int
    let totalPrice: Double
    let onPay: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                Text(CartLocalizedText.nftCount(count).key)
                    .font(.regular15)
                    .foregroundStyle(Color(.fnText))
                Text(PriceFormatter.string(from: totalPrice))
                    .font(.bold17)
                    .foregroundStyle(Color(.fnGreen))
            }
            Button(action: onPay) {
                Text(CartLocalizedText.toPayment.key)
                    .font(.bold17)
                    .foregroundStyle(Color(.fnBackground))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color(.fnText))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .fill(Color(.fnLightGray))
        )
    }
}

#Preview {
    CartSummaryPanel(count: 3, totalPrice: 5.34) {}
}
