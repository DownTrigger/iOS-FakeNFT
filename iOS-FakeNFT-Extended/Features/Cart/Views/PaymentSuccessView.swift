import SwiftUI

struct PaymentSuccessView: View {
    @Environment(Router<CartRoute>.self) private var router

    private let imageSize: CGFloat = 278

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(.imgPaymentSuccess)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
            Text(CartLocalizedText.paymentSuccess.key)
                .font(.bold22)
                .foregroundStyle(Color(.fnText))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.horizontal, 16)
            Spacer()
            backToCartButton
        }
        .frame(maxWidth: .infinity)
        .background(Color(.fnBackground))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
    }

    private var backToCartButton: some View {
        Button {
            router.popToRoot()
        } label: {
            Text(CartLocalizedText.backToCart.key)
                .font(.bold17)
                .foregroundStyle(Color(.fnBackground))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.fnText))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding([.horizontal, .bottom], 16)
    }
}

#Preview {
    NavigationStack {
        PaymentSuccessView()
    }
    .environment(Router<CartRoute>())
}
