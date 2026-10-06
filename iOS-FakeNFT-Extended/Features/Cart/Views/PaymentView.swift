import SwiftUI

struct PaymentView: View {
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 2)
    private static let agreementURL = URL(string: "https://yandex.ru/legal/practicum_termsofuse")

    @Environment(ServicesAssembly.self) private var services
    @Environment(Router<CartRoute>.self) private var router
    @State private var viewModel = PaymentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            content
            bottomPanel
        }
        .background(Color(.fnBackground))
        .overlay {
            if viewModel.isPaying {
                AppLoadingView()
            }
        }
        .navigationTitle(CartLocalizedText.paymentTitle.text)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(.icBack)
                        .renderingMode(.template)
                        .foregroundStyle(Color(.fnText))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task { await viewModel.load(using: services.paymentService) }
        .appAlert(item: $viewModel.alert)
        .onChange(of: viewModel.isPaid) { _, isPaid in
            if isPaid {
                router.push(.success)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if case .loading = viewModel.state {
            AppLoadingView()
        } else {
            ScrollView {
                LazyVGrid(columns: Self.columns, spacing: 7) {
                    ForEach(viewModel.currencies) { currency in
                        CurrencyCell(
                            currency: currency,
                            isSelected: currency.id == viewModel.selectedCurrency?.id
                        )
                        .onTapGesture {
                            viewModel.select(currency)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 0) {
                Text(CartLocalizedText.agreementText.key)
                    .foregroundStyle(Color(.fnText))
                Button {
                    if let url = Self.agreementURL {
                        router.push(.agreement(url))
                    }
                } label: {
                    Text(CartLocalizedText.agreementLink.key)
                        .foregroundStyle(Color(.fnBlue))
                }
            }
            .font(.regular13)

            PrimaryButton(title: .pay, action: pay, isDisabled: !viewModel.canPay)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
                .fill(Color(.fnLightGray))
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func pay() {
        Task {
            await viewModel.pay(using: services.paymentService, cartService: services.cartService)
        }
    }
}

#Preview {
    NavigationStack {
        PaymentView()
    }
    .environment(ServicesAssembly(networkClient: DefaultNetworkClient(), nftStorage: NftStorageImpl()))
    .environment(Router<CartRoute>())
}
